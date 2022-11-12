require("regenerator-runtime/runtime"); // required for sleep (https://github.com/babel/babel/issues/9849#issuecomment-487040428)

const Chessground = require('chessground').Chessground;
const Chess = require('chess.js')
import { turn_color, setup_chess, uci_to_san, san_to_uci } from './modules/chess_utils.js';
import { string_hash } from './modules/hash.js';
import { clear_local_storage } from './modules/localstorage.js';
import { tree_value_add, tree_progress, tree_move_index, tree_children, tree_possible_moves, has_children, tree_value,
         need_hint, update_value, value_sort, tree_get_node, tree_children_filter_sort } from './modules/tree_utils.js';
import { generate_move_trees, annotate_pgn } from './modules/tree_from_pgn.js';
import { sleep } from './modules/sleep.js';
import { getRandomIntFromRange } from './modules/random.js';
import { unescape_string } from './modules/security_related.js';
import { ground_init_state, onresize, resize_ground, setup_ground, ground_set_moves,
         ground_undo_last_move, setup_move_handler, ground_move } from './modules/ground.js';
import { set_text, clear_all_text, success_div, info_div, error_div, suggestion_div } from './modules/info_boxes.js';

const mode_free = "free_mode";

const comments_div = "comments";

let move_delay_time = i18n.instant;

let combo_count = 0;
let show_arrows = true;
let board_review = false;
// Note: When enabled, will skip to the first branch point in the PGN tree. If the move list is flat then this has no effect.
let key_moves_mode = true;
// Note: NULL if disabled, otherwise an integer value based on the PGN move number.
let max_depth_mode = null;

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

    let possible_moves = tree_possible_moves(curr_move);

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
        if (!end_of_line && max_depth_mode !== null) {
            let curr_node = tree_get_node(curr_move);
            let curr_depth = curr_node.move_index == 0 ? 1 : 1 + Math.floor(curr_node.move_index / 2);
            if (!key_moves_mode || window.first_variation === null) {
                end_of_line = curr_depth >= max_depth_mode;
            } else {
                end_of_line = curr_node.move_index >= window.first_variation && curr_depth >= max_depth_mode;
            }
            // console.log('CURR_DEPTH', end_of_line, curr_node.move, curr_node.move_index, curr_depth);
        }
        await sleep(get_move_delay()); // instant play by the ai feels weird
        if (end_of_line) {
            achievement_end_of_line();
            set_text(success_div, right_move_text() + "\n" + i18n.success_end_of_line);
            if (board_review) {
                // user wants to do the slow board reset
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

function give_hints(access) {
    // need_hint also filters for has_children
    let to_hint = tree_possible_moves(access, {filter: need_hint});
    let shapes = [];
    for (let m of to_hint) {
        let ft = san_to_uci(chess, m);
        shapes.push({orig: ft.from, dest: ft.to, brush: "hint"});
    }
    if (show_arrows) {
        ground.setShapes(shapes);
    }
    ground.redrawAll(); //TODO figure out how to remove this
}

/*
 * Display comments for moves that need hints and the current move
 */
function display_comments(access) {
    let cm = tree_get_node(access);
    let comment = "";
    let to_hint = tree_children_filter_sort(access, {filter: need_hint});
    for (let m of to_hint) {
        if (m.comments != undefined && m.comments[0] != undefined && m.comments[0].text != undefined) {
            comment += m.comments[0].text + "\n";
        }
    }

    // give comment on the current move if there are move to give hint to
    if (to_hint.length > 0 && cm.comments != undefined && cm.comments[0] != undefined && cm.comments[0].text != undefined) {
        comment += cm.comments[0].text;
    }

    // set_text is save to use with untrusted strings
    // => we can use unescape_string
    set_text(comments_div, unescape_string(comment));
}

function change_play_stockfish() {
    let fen = chess.fen();
    let link = document.getElementById("play_stockfish");
    let base = link.href.split("#")[0];
    link.href = `${base}#${fen}`;
}

function setup_move() {
    change_play_stockfish();
    give_hints(curr_move);
    show_suggestions();
    display_comments(curr_move);
    ground_set_moves(); // the legal moves of the position
}

/*
 * Returns the ai move that should be played for the access position
 * the move should be the one with the lowest value or the move
 * played the latest
 */
function ai_move(access) {
    let m = tree_possible_moves(access, {filter: has_children, sort: value_sort})[0];
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
    if (key_moves_mode && window.first_variation !== null) {
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
    let selected = localStorage.getItem(select_key) || 0;
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

    if (max == 0) {
        set_text(suggestion_div, i18n.info_arrows);
    }
}

function toggle_arrows() {
    let link = document.getElementById("arrows_toggle");
    let curr = link.attributes["data-icon"].textContent;
    let next = curr == "%" ? "$" : "%";
    link.setAttribute("data-icon", next);
    if (next == "$") {
        // currently hidden
        link.textContent = i18n.arrows_show;
        show_arrows = false;
        ground.setShapes([]);
    } else {
        link.textContent = i18n.arrows_hide;
        show_arrows = true;
        give_hints(curr_move);
    }
}

function toggle_key_move() {
    let link = document.getElementById("key_move");
    let curr = link.attributes["data-icon"].textContent;
    let next = curr == "%" ? "$" : "%";
    link.setAttribute("data-icon", next);
    if (next == "%") {
        link.textContent = i18n.key_move_enabled;
        key_moves_mode = false;
    } else {
        link.textContent = i18n.key_move_disabled;
        key_moves_mode = true;
    }
}

function toggle_review() {
    let link = document.getElementById("line_review");
    let curr = link.attributes["data-icon"].textContent;
    let next = curr == "%" ? "$" : "%";
    link.setAttribute("data-icon", next);
    if (next == "$") {
        link.textContent = i18n.review_fast;
        board_review = true;
    } else {
        link.textContent = i18n.review_slow;
        board_review = false;
    }
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
            curr = i18n.instant;
            break;
    }
    span.textContent = curr;
    move_delay_time = curr;
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
        }
    }
}

function setup_configs() {
    document.getElementById("arrows_toggle").onclick = toggle_arrows;
    document.getElementById("line_review").onclick = toggle_review;
    document.getElementById("move_delay").onclick = toggle_move_delay;
    document.getElementById("key_move").onclick = toggle_key_move;
}

function main() {
    setup_ground();
    setup_chess();
    setup_trees();
    setup_chapter_select();
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
