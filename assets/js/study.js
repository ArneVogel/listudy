require("regenerator-runtime/runtime"); // required for sleep (https://github.com/babel/babel/issues/9849#issuecomment-487040428)

const Chessground = require('chessground').Chessground;
const Chess = require('chess.js')
import { turn_color, non_turn_color, setup_chess, uci_to_san, san_to_uci } from './modules/chess_utils.js';
import { string_hash } from './modules/hash.js';
import { clear_local_storage, get_option_from_localstorage } from './modules/localstorage.js';
import { tree_value_add, tree_progress, tree_move_index, tree_children, tree_possible_moves, has_children, tree_value,
         need_hint, update_value, value_sort, tree_get_node, tree_children_filter_sort, tree_get_node_depth,
         tree_get_node_string, tree_size_weighted_random_move, tree_max_num_moves_deep } from './modules/tree_utils.js';
import { generate_move_trees, annotate_pgn } from './modules/tree_from_pgn.js';
import { sleep } from './modules/sleep.js';
import { getRandomIntFromRange } from './modules/random.js';
import { unescape_string } from './modules/security_related.js';
import { ground_init_state, onresize, resize_ground, setup_ground, ground_set_moves,
         ground_undo_last_move, setup_move_handler, ground_move } from './modules/ground.js';
import { set_text, clear_all_text, success_div, info_div, error_div, suggestion_div } from './modules/info_boxes.js';

const mode_free = "free_mode";

const comments_div = "comments";

let combo_count = 0;

// Option to control how quickly the ai plays each move
let move_delay_time_key = "move_delay_time";
let move_delay_time = get_option_from_localstorage(move_delay_time_key, i18n.instant, [i18n.instant, i18n.fast, i18n.medium, i18n.slow]);

// Option to control how and when arrows are displayed
let show_arrows_key = "show_arrows";
let show_arrows = get_option_from_localstorage(show_arrows_key, i18n.arrows_new2x, [i18n.arrows_new2x, i18n.arrows_new5x, i18n.arrows_always, i18n.arrows_hidden]);

// Option to control how and when arrows are displayed
let arrow_type_key = "arrow_type";
let arrow_type = get_option_from_localstorage(arrow_type_key, i18n.arrow_type_both, [i18n.arrow_type_auto, i18n.arrow_type_pgn, i18n.arrow_type_both]);

// When enabled the board waits a few seconds at the end of the line before resetting.
let board_review_key = "board_review";
let board_review = get_option_from_localstorage(board_review_key, i18n.review_fast, [i18n.review_fast, i18n.review_slow]);

// When enabled, will skip to the first branch point in the PGN tree. If the move list is flat then this has no effect.
let key_moves_mode_key = "key_moves_mode";
let key_moves_mode = get_option_from_localstorage(key_moves_mode_key, i18n.key_move_enabled, [i18n.key_move_enabled, i18n.key_move_disabled]);

//  When enabled the comments from the opposite side's responses are also shown.
let show_comments_key = "show_comments";
let show_comments = get_option_from_localstorage(show_comments_key, i18n.comments_when_arrows, [i18n.comments_when_arrows, i18n.comments_always_on, i18n.comments_hidden]);

// Option to control the maximum number of moves being played
const DEPTH_MAX = -1;  // This constant is used to avoid having to calculate the tree depth when max_depth is at the max depth.
let max_depth_key_base = "max_depth_" + study_id + "_";
let max_depth = DEPTH_MAX;

function combo_text() {
    return "" + combo_count + "x ";
}

function right_move_text() {
    return combo_text() + i18n.success_right_move;
}

function achievement_end_of_line() {
    let t = localStorage.getItem("achievements_lines_learned") || 0;
    localStorage.setItem("achievements_lines_learned", Number(t) + 1);
    if (typeof achievement_student_test != "undefined") {
        document.dispatchEvent(achievement_student_test);
    }
    if (typeof achievement_student2_test != "undefined") {
        document.dispatchEvent(achievement_student2_test);
    }

}

// "cxb8=Q" => "cxb8="
// "abc" => ""
function san_promotion_prefix(san) {
    return san.substring(0, san.indexOf("=") + 1); 
}

// checks if the san would be a possible promotion
// expected result for 
//  moves: Array [ "cxb8=N" ]
//  san:   cxb8=Q
// would be "cxb8=Q.
// Returns "" if the san is not a possible promotion
// Used in handle_move to allow for underpromotions
function possible_promotion(moves, san) {
    let target_prefix = san_promotion_prefix(san);

    // this move did not promote
    if (target_prefix == "") {
        return ""; 
    }
    for (let m of moves) {
        let prefix = san_promotion_prefix(m);
        if (prefix == "") {
            continue;
        }
        if (prefix == target_prefix) {
            return m;
        }
    }
    return ""; 
}

async function handle_move(orig, dest) {

    clear_all_text();

    total_moves += 1;

    let san = uci_to_san(chess, orig, dest);

    let possible_moves = tree_possible_moves(curr_move).map(m => m.move);

    let possible_promotion_san = possible_promotion(possible_moves, san);
    // the move automatically promoted to a queen, above we checked if it was
    // also possible to underpromote, if so we returned that san instead
    if (possible_promotion_san != "") {
        san = possible_promotion_san;
    }

    if(possible_moves.indexOf(san) != -1) {
        // console.log('curr_move', orig, dest, JSON.stringify(curr_move));
        // the move is one of the possible moves in the current position
        update_value(curr_move, 1, san);
        play_move(san);
        combo_count += 1;
        set_text(success_div, right_move_text());
        let reply = ai_move(curr_move);
        let end_of_line = reply == undefined;
        if (!end_of_line && max_depth !== DEPTH_MAX) {
            let curr_node = tree_get_node(curr_move);
            let curr_depth = tree_get_node_depth(curr_node);
            if (key_moves_mode == i18n.key_move_disabled || window.first_variation === null) {
                end_of_line = curr_depth >= max_depth;
            } else {
                end_of_line = curr_node.move_index >= window.first_variation && curr_depth >= max_depth;
            }
            // console.log('CURR_DEPTH', end_of_line, curr_node.move, curr_node.move_index, curr_depth);
        }
        await sleep(get_move_delay()); // instant play by the ai feels weird
        if (end_of_line) {
            achievement_end_of_line();
            set_text(success_div, right_move_text() + "\n" + i18n.success_end_of_line);
            if (board_review == i18n.review_slow) {
                await sleep(3000);
            }
            start_training();
        } else {
            play_move(reply);
        }
    } else {
        // wrong move at the current position
        update_value(curr_move, 0); //retrain all the possible replies
        combo_count = 0; //reset the combo
        // it is important that chess is set to the right position before
        // calling ground_undo_last_move(); since it used chess.fen() to
        // reset the position to the previous position
        ground_undo_last_move();
        set_text(error_div, i18n.error_wrong_move);
    }
    store_trees();
    setup_move();
    update_progress();
}

function create_shape(move, brush) {
    let ft = san_to_uci(chess, move);
    return {orig: ft.from, dest: ft.to, brush: brush};
}

/**
 * 
 * @param {*} m 
 * @param {*} max 
 * @param {*} min 
 * @param {*} pgn_color 
 * @returns 
 */
function create_auto_arrow(m, max, min, pgn_color = undefined) {
    let move = m.move;
    let some_neglected = min < (0.5 * max);
    let current_neglected = m.value < (0.5 * max);
    let brush = undefined;
    if(pgn_color) {  // pgn arrows
        let brush_prefix = some_neglected ? 
            (current_neglected ? "playable_pgn_normal_" : "playable_pgn_transparent_") : "playable_pgn_normal_";
        brush = brush_prefix + pgn_color;
    } else {  // normal auto arrows
        brush = some_neglected ? (current_neglected ? "normal" : "transparent") : "normal";
    }
    return create_shape(move, brush);
}

function create_pgn_arrow(cal, brush_prefix = "") {
    let brush = brush_prefix + get_color_from_cal(cal);
    let from = cal.substr(1, 2);
    let to = cal.substr(3, 2);
    //let modifiers = combined ? {lineWidth: 5} : {};
    let modifiers = {};
    return {orig: from, dest: to, brush: brush, modifiers: modifiers};
}

function create_pgn_circle(csl) {
    let brush = get_color_from_cal(csl);
    let from = csl.substr(1, 2);
    return {orig: from, brush: brush};
}

/**
 * Returns true if arrows should be shown.
 */
function give_hints(once) {
    if (once || show_arrows == i18n.arrows_always) {
        return true;
    }

    let all_moves = tree_possible_moves(curr_move);
    let min = Math.min(...all_moves.map(m => m.value));
    if (show_arrows == i18n.arrows_new2x && min < 2 ||
        show_arrows == i18n.arrows_new5x && min < 5) {
        return true;
    }
    return false;
}

function get_pgn_shapes(m, keyword) {
    if (m.comments != undefined) {
        let commands = m.comments.filter(c => c.commands != undefined).flatMap(c => c.commands);
        return commands.filter(cmd => cmd.key == keyword).flatMap(cmd => cmd.values);
    } else {
        return [];
    }
}

function array_contains(arr, str) {
    return arr.indexOf(str) > -1;
}

function get_color_from_cal(cal) {
    let c = cal[0];
    switch (c) {
        case "G":
            return "green";
        case "R":
            return "red";
        case "Y":
            return "yellow";
        case "B":
        default:
            return "blue";
    }
}

function get_arrow_code_from_cal(cal) {
    return cal.substr(1,4);
}

function get_arrow_code_from_move(m) {
    let uci = san_to_uci(chess, m.move);
    return "" + uci.from + uci.to;
}

function get_doubled_auto_moves_objects(all_moves, all_pgn_arrows) {
    // Setup some lookup tables
    let all_pgn_arrow_codes = [];
    let color_by_pgn_arrow = {};
    for (let cal of all_pgn_arrows) {
        let arrow_code = get_arrow_code_from_cal(cal);
        let color = get_color_from_cal(cal);
        
        color_by_pgn_arrow[arrow_code] = color;
        all_pgn_arrow_codes.push(arrow_code);
    }

    // Merge the playable moves and the pgn arrows
    let auto_pgn_union = all_moves.map(move => {
        let arrow_code = get_arrow_code_from_move(move);
        let color = color_by_pgn_arrow[arrow_code];
        return {
            color: color,
            arrow_code: arrow_code,
            move: move
        };
    })
    // And filter so that only those moves that are both playable a pgn arrow are left
    let filtered_moves = auto_pgn_union.filter(x => array_contains(all_pgn_arrow_codes, x.arrow_code))
    return filtered_moves;
}

/**
 * Update the hints/arrows on the board, depending on the current setting of the variable show_arrows.
 * @param {*} once  Pass true to override any value of variable show_arrows and display hints temporarily.
 */
function display_arrows(once) {
    let all_moves = tree_possible_moves(curr_move);
    let current_move = tree_get_node(curr_move);
    let min = Math.min(...all_moves.map(m => m.value));
    let max = Math.max(...all_moves.map(m => m.value));
    let shapes = [];

    if (!give_hints(once)) {
        ground.setShapes(shapes);
        return;
    }

    if (arrow_type == i18n.arrow_type_auto) {
        shapes.push(...all_moves.map(m => create_auto_arrow(m, max, min)));

    } else if (arrow_type == i18n.arrow_type_pgn) {
        let all_pgn_circles = get_pgn_shapes(current_move, "csl");
        let all_pgn_arrows = get_pgn_shapes(current_move, "cal");

        shapes.push(...all_pgn_circles.map(a => create_pgn_circle(a)));
        shapes.push(...all_pgn_arrows.map(a => create_pgn_arrow(a)));

    } else if (arrow_type = i18n.arrow_type_both) {
        let all_pgn_circles = get_pgn_shapes(current_move, "csl");
        shapes.push(...all_pgn_circles.map(a => create_pgn_circle(a)));

        let all_pgn_arrows = get_pgn_shapes(current_move, "cal");
        let all_pgn_arrows_str = all_pgn_arrows.map(cal => get_arrow_code_from_cal(cal));
        let clean_auto_moves = all_moves.filter(m => !array_contains(all_pgn_arrows_str, get_arrow_code_from_move(m)));
        //let doubled_auto_moves = all_moves.filter(m => array_contains(all_pgn_arrows_str, get_arrow_cmd_from_move(m)));
        let doubled_auto_moves_objects = get_doubled_auto_moves_objects(all_moves, all_pgn_arrows);
        let all_auto_arrows = all_moves.map(m => get_arrow_code_from_move(m));
        let decorate_pgn_arrows = all_pgn_arrows.filter(cal => !array_contains(all_auto_arrows, get_arrow_code_from_cal(cal)));
        // let playable_pgn_arrows = all_pgn_arrows.filter(cal => array_contains(all_auto_arrows, get_arrow_cmd_from_cal(cal)));

        // Pick one
        //shapes.push(...clean_auto_moves.map(m => create_pgn_arrow("B" + get_arrow_cmd_from_move(m), "playable_pgn_normal_")));
        shapes.push(...clean_auto_moves.map(m => create_auto_arrow(m, max, min, "blue")));

        shapes.push(...doubled_auto_moves_objects.map(x => create_auto_arrow(x.move, max, min, x.color)));
        //shapes.push(...playable_pgn_arrows.map(a => create_pgn_arrow(a, "playable_pgn_normal_")));

        shapes.push(...decorate_pgn_arrows.map(a => create_pgn_arrow(a, "decorate_pgn_")));

    }
    ground.setShapes(shapes);
}

function capitalize_first_letter(word) {
    return word.charAt(0).toUpperCase() + word.slice(1);
}

function create_comment(container_div, response_num, move) {
    var comment_div = document.createElement('div');
    comment_div.id = 'comment' + response_num;

    var bold_text_elem = document.createElement('div');
    bold_text_elem.id = comment_div.id + "_bold";
    bold_text_elem.className = "bold";

    var comment_text_elem = document.createElement('div');
    comment_text_elem.id = comment_div.id + "_text";
    comment_text_elem.className = "text";

    comment_div.appendChild(bold_text_elem);
    comment_div.appendChild(comment_text_elem);
    container_div.appendChild(comment_div);

    let response_color = capitalize_first_letter(turn_color(chess));
    let move_color = capitalize_first_letter(non_turn_color(chess));
    let ext_san = tree_get_node_string(move);
    let current_move = response_num == undefined;
    let before_start = current_move && move.move == undefined;
    let first_move = move.move_index == 0;
    let text = unescape_string(move.comments[0].text.trim());
    let bold_text = undefined;

    if (before_start) {
        bold_text = "";
    } else if (current_move) {
        bold_text = move_color + " " + ext_san + ":"
    } else {  // response move
        bold_text = response_color + " " + (!first_move ? i18n.response : "") + " " + ext_san + ":";
    }

    set_text(comment_div.id, text, { bold_text: bold_text });
}

function create_comment_list(container_id, current_move, response_moves) {
    let container_div = document.getElementById(container_id);
    container_div.innerHTML = '';

    if (current_move != undefined) {
        create_comment(container_div, undefined, current_move);
    }

    for (let [i, move] of response_moves.entries()) {
        create_comment(container_div, i, move, true);
    }
}

/*
 * Display comments, either only for the current move, or for the opposite side's responses as well
 * if that option is turned on.
 */
function display_comments(once) {
    let cm = tree_get_node(curr_move);
    let current_move = undefined;
    let response_moves = [];

    if (once || show_comments == i18n.comments_always_on ||
        show_comments == i18n.comments_when_arrows && give_hints(once)) {

        // Get current move if it has a comment
        if (cm.comments != undefined && cm.comments[0] != undefined && cm.comments[0].text != undefined) {
            current_move = cm;
        }
        // Get the reponse moves that has comments
        let children = tree_children(curr_move);
        if (children.length > 0) {
            for (let m of children) {
                if (m.comments != undefined && m.comments[0] != undefined && m.comments[0].text != undefined) {
                    response_moves.push(m);
                }
            }
        }
    }

    create_comment_list("comments", current_move, response_moves);
}

function change_play_stockfish() {
    let fen = chess.fen();
    let link = document.getElementById("play_stockfish");
    let base = link.href.split("#")[0];
    link.href = `${base}#${fen}`;
}

function change_analysis_board() {
    let pgn = encodeURIComponent(chess.pgn());
    let color = turn_color(chess);
    let link = document.getElementById("analysis_board");
    link.href = `https://lichess.org/analysis/pgn/${pgn}?color=${color}`;
}

function setup_move() {
    change_play_stockfish();
    change_analysis_board();
    display_arrows(false);
    show_suggestions();
    display_comments(false);
    ground_set_moves(); // the legal moves of the position
}

/*
 * Returns the ai move that should be played for the access position
 */
function ai_move(access) {
    //console.log('Finding moves after ' + (tree_get_node(access).move_index > 0 ? tree_get_node_string(tree_get_node(access)) : 'starting position'));

    let candidates = tree_children_filter_sort(access, {filter: has_children});
    let m = tree_size_weighted_random_move(candidates);

    // change the last updated value of the node so if other moves exists they will be
    // picked next time instead
    if (m !== undefined) {
        update_value(access, 1, m);
    }
    return m;
}

/*
 * Plays a move in san notation
 * Update chess, ground, access
 */
function play_move(san) {
    let m = chess.move(san);
    ground_move(m);
    curr_move.push(tree_move_index(curr_move, san));
}

function start_training() {
    window.curr_move = [chapter];
    window.first_variation = trees[chapter].first_variation;
    // this fen is the normal chess starting position
    let fen = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1";
    if ("headers" in trees[chapter]) {
        fen = trees[chapter].headers.FEN || fen;
    }
    setup_chess(fen);
    ground_init_state(fen);
    if (key_moves_mode == i18n.key_move_enabled && window.first_variation !== null) {
        for (let ki = 0; ki < window.first_variation; ++ki) {
            // Moves that are not fully trained are not skipped
            if (tree_children(curr_move)[0].value != 5) { break; }
            // Multiple moves are played without delay, causes distorted sound
            // sound_enabled controls if sound is played in sound.js
            // the sounds are initiated by ground.move which is used by play_move
            let stored_sound = sound_enabled;
            sound_enabled = false;
            play_move(ai_move(curr_move));
            sound_enabled = stored_sound;
        }
    }
    if (color != turn_color(chess)) {
        play_move(ai_move(curr_move));
    }
    setup_move();

    /* TODO figure out how to remove this. This is a workaround to make sure arrows appear right from
    the start. Without this, setShapes() in display_arrows() appear to have no effect. It's only needed the
    first time hints are displayed, so this is a good location. The redraw scrolls the page to the top
    on mobile devices, and having the call in display_arrows() then forces a scroll to the top every time
    the user makes a move or changes the Arrows option. Hours have been spent on this bug. Could be a
    bug in chessground. */
    ground.redrawAll();

    window.mode = mode_free;
}

/*
 * Store the trees in window.trees into localStorage
 */
function store_trees() {
    let tree_key = study_id + "_tree";
    localStorage.setItem(tree_key, JSON.stringify(trees));
}

// load the trees from the localStorage or generate if they dont exist
function setup_trees() {
    let hash_key = study_id + "_hash";
    let tree_key = study_id + "_tree";

    let last_hash = localStorage.getItem(hash_key);
    let curr_hash = string_hash(pgn + color);
    curr_hash += 3; // increase when trees have to be redone; for example when bugs in free_from_pgn are fixed
    let trees = {};

    if (last_hash == undefined || curr_hash != last_hash) {
        const pgnParser = require('pgn-parser'); // slows down page load, so only require if actually needed
        try {
            const parsedpgn = pgnParser.parse(pgn);
            annotate_pgn(parsedpgn);
            trees = generate_move_trees(parsedpgn);
            clear_local_storage();
            localStorage.setItem(hash_key, curr_hash);
            localStorage.setItem(tree_key, JSON.stringify(trees));
        } catch(caught_error) {
            console.log(caught_error);
            let error_text = caught_error.name + " at line: " + caught_error.location.start.line +
                             ", character: " + caught_error.location.start.column + "; Unexpected: \"" +
                             caught_error.found + "\"";
            set_text(error_div, error_text);
        }
    } else {
        trees = JSON.parse(localStorage.getItem(tree_key));
    }
    window.trees = trees;
}

/*
 * Returns the name of the event or a generic Chapter 1 if no event is present
 */
function tree_chapter_name(tree_index) {
    return trees[tree_index].headers.Event || i18n.translation_chapter + " " + (tree_index+1);
}

// generate the chapter selection below the game board
// the chapter value is the id for the tree to use
function setup_chapter_select() {
    let select_key = study_id + "_selected";
    let select_id = "chapter_select"
    let select = document.getElementById(select_id);
    let selected = parseInt(localStorage.getItem(select_key) || 0);
    selected = Math.min(selected, trees.length - 1);  // prevent error if uploading a pgn with fewer chapters
    window.chapter = selected;
    for (let i = 0; i < trees.length; ++i) {
        let option = document.createElement("option");
        option.value = i;
        let name = tree_chapter_name(i);
        option.innerText = name;
        if (i == selected) {
            option.selected = true;
        }
        select.appendChild(option);
    }

    select.onchange = function() {
        let v = document.getElementById(select_id).value;
        localStorage.setItem(select_key, v);
        window.chapter = v;
        start_training();
        update_progress(); // update the progress bar shown
        set_options_values_for_max_depth();  // update the max depth for the new chapter
    };
}

/*
 * Show suggestions based on the move number
 */
function show_suggestions() {
    let suggestions = [
        {move: 15, show: true, text: i18n.suggestion_share, once: true, key: "share"},
        {move: 30, show: logged_in, text: i18n.suggestion_favorite, once: true, key: "favorite"},
        {move: 30, show: !logged_in, text: i18n.suggestion_account, once: false, key: "account"},
        {move: 50, show: logged_in, text: i18n.suggestion_comment, once: true, key: "comment"},
        {move: 100, show: true, text: i18n.suggestion_100moves, once: false, key: "100moves"},
        {move: 250, show: true, text: i18n.suggestion_250moves, once: false, key: "250moves"}
    ]

    for (let suggestion of suggestions) {
        let lsKey = study_id + "_suggestions_" + suggestion.key;
        let alreadySuggested = localStorage.getItem(lsKey) || false;
        if (total_moves == suggestion.move && suggestion.show && !(suggestion.once && alreadySuggested)) {
            set_text(suggestion_div, suggestion.text);
            localStorage.setItem(lsKey, true);
        }
    }
}

function setup_intro() {
    set_text(info_div, i18n.info_intro);

    let roots = trees.map(x => x.root[0]);
    let max = Math.max(...roots.map(x => tree_value(x, Math.max)));

    if (max == 0 && show_arrows == i18n.arrows_new2x) {
        set_text(suggestion_div, i18n.info_arrows);
    }
}

function turn_on_hints_for_current_move() {
    display_arrows(true);
    display_comments(true);
}

function toggle_arrows() {
    let span = document.getElementById("arrows_toggle");
    let curr = span.textContent;
    switch (curr) {
        case i18n.arrows_new2x:
            curr = i18n.arrows_new5x;
            break;
        case i18n.arrows_new5x:
            curr = i18n.arrows_always;
            break;
        case i18n.arrows_always:
            curr = i18n.arrows_hidden;
            break;
        case i18n.arrows_hidden:
        default:
            curr = i18n.arrows_new2x;
            break;
    }
    span.textContent = curr;
    show_arrows = curr;
    display_arrows(false);
    display_comments(false);
    localStorage.setItem(show_arrows_key, show_arrows);
}

function toggle_arrow_type() {
    let span = document.getElementById("arrow_type");
    let curr = span.textContent;
    switch (curr) {
        case i18n.arrow_type_auto:
            curr = i18n.arrow_type_pgn;
            break;
        case i18n.arrow_type_pgn:
            curr = i18n.arrow_type_both;
            break;
        case i18n.arrow_type_both:
        default:
            curr = i18n.arrow_type_auto;
            break;
    }
    span.textContent = curr;
    arrow_type = curr;
    display_arrows(false);
    display_comments(false);
    localStorage.setItem(arrow_type_key, arrow_type);
}

function toggle_key_move() {
    let link = document.getElementById("key_move");
    let curr = link.textContent;
    switch (curr) {
        case i18n.key_move_enabled:
            curr = i18n.key_move_disabled;
            link.setAttribute("data-icon", "%");
            break;
        case i18n.key_move_disabled:
        default:
            curr = i18n.key_move_enabled;
            link.setAttribute("data-icon", "$");
            break;
    }
    key_moves_mode = curr;
    link.textContent = curr;
    localStorage.setItem(key_moves_mode_key, key_moves_mode);
}

function toggle_review() {
    let link = document.getElementById("line_review");
    let curr = link.textContent;
    switch (curr) {
        case i18n.review_fast:
            curr = i18n.review_slow;
            break;
        case i18n.review_slow:
        default:
            curr = i18n.review_fast;
            break;
    }
    board_review = curr;
    link.textContent = curr;
    localStorage.setItem(board_review_key, board_review);
}

function toggle_move_delay() {
    let span = document.getElementById("move_delay_time");
    let curr = span.textContent;
    switch (curr) {
        case i18n.instant:
            curr = i18n.fast;
            break;
        case i18n.fast:
            curr = i18n.medium;
            break;
        case i18n.medium:
            curr = i18n.slow;
            break;
        case i18n.slow:
        default:
            curr = i18n.instant;
            break;
    }
    span.textContent = curr;
    move_delay_time = curr;
    localStorage.setItem(move_delay_time_key, move_delay_time);
}


function get_move_delay() {
    let delay = 300;
    switch (move_delay_time) {
        case i18n.instant:
            delay = 300;
            break;
        case i18n.fast:
            delay = getRandomIntFromRange(500, 1500);
            break;
        case i18n.medium:
            delay = getRandomIntFromRange(1500, 3000);
            break;
        case i18n.slow:
            delay = getRandomIntFromRange(5000, 10000);
            break;
        default:
            console.log("Got non supported move delay: ", move_delay_time);
            delay = 300;
    }
    return delay;
}

function toggle_comments() {
    let link = document.getElementById("comments_toggle");
    let curr = link.textContent;
    switch (curr) {
        case i18n.comments_always_on:
            curr = i18n.comments_hidden;
            break;
        case i18n.comments_hidden:
            curr = i18n.comments_when_arrows;
            break;
        case i18n.comments_when_arrows:
        default:
            curr = i18n.comments_always_on;
            break;
        }
    link.textContent = curr;
    show_comments = curr;
    display_comments(false);
    localStorage.setItem(show_comments_key, show_comments);
}

function get_repertoire_depth() {
    let starting_moves = trees[chapter].root;
    return tree_max_num_moves_deep(starting_moves);
}

function add_sub_max_depth(delta) {
    let tree_depth = get_repertoire_depth();
    let max_depth_label = document.getElementById("max_depth_label");
    let max_depth_range = document.getElementById("max_depth_range");
    let depth = parseInt(max_depth_label.textContent, 10) || tree_depth;
    depth += delta;
    // Make sure it's not lower than 1 or higher than the actual depth of the tree
    depth = delta > 0 ? Math.min(depth, tree_depth) : Math.max(depth, 1);
    max_depth_label.textContent = depth;
    max_depth_range.value = depth;
    max_depth = depth == tree_depth ? DEPTH_MAX : depth;
    localStorage.setItem(max_depth_key_base + chapter, max_depth);
}

function max_depth_changed() {
    let tree_depth = get_repertoire_depth();
    let max_depth_range = document.getElementById("max_depth_range");
    let max_depth_label = document.getElementById("max_depth_label");
    let depth = max_depth_range.value || tree_depth;
    max_depth_label.innerHTML = depth;
    max_depth = depth == tree_depth ? DEPTH_MAX : depth;
    localStorage.setItem(max_depth_key_base + chapter, max_depth);
}

function reset_line() {
    start_training();
}

/*
 * Updates the progress modal html
 */
async function update_progress() {
    let d = document.getElementById("study_progress");
    d.innerHTML = "";

    for (let tree_index in trees) {
        let chapter_name = tree_chapter_name(tree_index);
        let tree = trees[tree_index];
        let progress = tree_progress(trees[tree_index].root[0]);
        let percent = parseInt( (progress[0] / progress[1]) * 100);
        let name = document.createElement("b");
        name.innerText = `${chapter_name} (${percent}%)`;
        d.appendChild(name);
        d.innerHTML += `
        <div class="progress-bar">
            <span id="progress" class="progress-bar-fill" style="width: ${percent}%;"></span>
        </div>
        `
    }

    let cp = document.getElementById("chapter_progress");
    let chapter_index = parseInt(chapter);
    let progress = tree_progress(trees[chapter].root[0]);
    let percent = parseInt( (progress[0] / progress[1]) * 100);
    cp.innerHTML = `
    <div class="progress-bar" title="${percent}%">
        <span id="progress" class="progress-bar-fill" style="width: ${percent}%;"></span>
    </div>
    `
}

async function setup_progress_reset() {
    let reset = document.getElementById("study_progress_reset");
    reset.onclick = function() {
        if (window.confirm(i18n.confirm_reset_progress)) {
            for (let c of trees) {
                tree_value_add(c.root[0], -5);
            }
            update_progress();
            display_arrows(false);
            display_comments(false);
        }
    }
}

/**
 * Initiate all option values on the page.
 */
function set_options_values() {
    let move_delay = document.getElementById("move_delay_time");
    move_delay.innerText = move_delay_time;

    let arrows_toggle = document.getElementById("arrows_toggle");
    arrows_toggle.innerText = show_arrows;

    let arrow_type_toggle = document.getElementById("arrow_type");
    arrow_type_toggle.innerText = arrow_type;

    let line_review = document.getElementById("line_review");
    line_review.innerText = board_review;

    let key_move = document.getElementById("key_move");
    key_move.innerText = key_moves_mode;
    key_move.setAttribute("data-icon", key_moves_mode == i18n.key_move_enabled ? "$" : "%");

    let comments_toggle = document.getElementById("comments_toggle");
    comments_toggle.innerText = show_comments;

    set_options_values_for_max_depth();
}

function set_options_values_for_max_depth() {
    // Option to control the maximum number of moves being played
    let max_depth_key = max_depth_key_base + chapter;
    max_depth = get_option_from_localstorage(max_depth_key, DEPTH_MAX, undefined, {validate: Number.isInteger, transform: parseInt});

    let max_depth_label = document.getElementById("max_depth_label");
    let max_depth_range = document.getElementById("max_depth_range");
    let tree_depth = get_repertoire_depth();
    let depth_as_num = max_depth == DEPTH_MAX ? tree_depth : max_depth;
    let depth = Math.min(tree_depth, depth_as_num);
    max_depth_label.innerHTML = depth
    max_depth_range.max = tree_depth;
    max_depth_range.value = depth;
}

function setup_configs() {
    document.getElementById("study_mainpage1").onclick = turn_on_hints_for_current_move;
    document.getElementById("study_mainpage2").onclick = turn_on_hints_for_current_move;
    document.getElementById("study_mainpage3").onclick = turn_on_hints_for_current_move;
    document.getElementById("hints").onclick = turn_on_hints_for_current_move;
    document.getElementById("arrows_toggle").onclick = toggle_arrows;
    document.getElementById("arrow_type").onclick = toggle_arrow_type;
    document.getElementById("line_review").onclick = toggle_review;
    document.getElementById("move_delay").onclick = toggle_move_delay;
    document.getElementById("key_move").onclick = toggle_key_move;
    document.getElementById("comments_toggle").onclick = toggle_comments;
    document.getElementById("reset_line").onclick = reset_line;
    document.getElementById("max_depth_sub").onclick = () => add_sub_max_depth(-1);
    document.getElementById("max_depth_add").onclick = () => add_sub_max_depth(+1);
    document.getElementById("max_depth_range").onchange = max_depth_changed;
    document.getElementById("max_depth_range").oninput = max_depth_changed;
}

function main() {
    setup_ground();
    setup_chess();
    setup_trees();
    setup_chapter_select();
    set_options_values();
    setup_move_handler(handle_move);

    window.total_moves = 0;

    resize_ground();

    setup_intro();

    start_training();
    setup_configs();
    update_progress();
    setup_progress_reset();
}

window.onresize = onresize;
main();
