require("regenerator-runtime/runtime"); // required for sleep (https://github.com/babel/babel/issues/9849#issuecomment-487040428)

const Chessground = require('chessground').Chessground;
const Chess = require('chess.js')
import { turn_color, setup_chess, uci_to_san, san_to_uci } from './modules/chess_utils.js';
import { string_hash } from './modules/hash.js';
import { tree_move_index, tree_children, tree_possible_moves, has_children, 
         need_hint, update_value, date_sort, tree_get_node, tree_children_filter_sort } from './modules/tree_utils.js';
import { generate_move_trees } from './modules/tree_from_pgn.js';
import { sleep } from './modules/sleep.js';
import { unescape_string } from './modules/security_related.js';
import { ground_init_state, resize_ground, setup_ground, ground_set_moves, 
         ground_undo_last_move, setup_move_handler, ground_move } from './modules/ground.js';
import { set_text, clear_all_text, success_div, info_div, error_div, suggestion_div } from './modules/info_boxes.js';

const mode_free = "free_mode";

const comments_div = "comments";

let combo_count = 0;

function combo_text() {
    return "" + combo_count + "x ";
}

function right_move_text() {
    return combo_text() + i18n.success_right_move;
}

async function handle_move(orig, dest) {

    clear_all_text();

    total_moves += 1;

    let san = uci_to_san(chess, orig, dest);
    
    let possible_moves = tree_possible_moves(curr_move);
    if(possible_moves.indexOf(san) != -1) {
        // the move is one of the possible moves in the current position
        update_value(curr_move, 1, san); 
        play_move(san);
        combo_count += 1;
        set_text(success_div, right_move_text());
        let reply = ai_move(curr_move);
        await sleep(300); // instant play by the ai feels weird
        if (reply == undefined) {
            set_text(success_div, right_move_text() + "\n" + i18n.success_end_of_line);
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
}

function give_hints(access) {
    // need_hint also filters for has_children
    let to_hint = tree_possible_moves(access, {filter: need_hint});
    let shapes = [];
    for (let m of to_hint) {
        let ft = san_to_uci(chess, m);
        shapes.push({orig: ft.from, dest: ft.to, brush: "hint"});
    }
    ground.setShapes(shapes);
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
    let m = tree_possible_moves(access, {filter: has_children, sort: date_sort})[0];
    // change the last updated value of the node so if other moves exists they will be
    // picked next time instead
    if (m !== undefined) {
        update_value(access, 0, m); 
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
    // this fen is the normal chess starting position
    let fen = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1";
    if ("headers" in trees[chapter]) {
        fen = trees[chapter].headers.FEN || fen;
    } 
    setup_chess(fen);
    ground_init_state(fen);
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
    curr_hash += 2; // increase when trees have to be redone; for example when bugs in free_from_pgn are fixed
    let trees = {};

    if (last_hash == undefined || curr_hash != last_hash) {
        const pgnParser = require('pgn-parser'); // slows down page load, so only require if actually needed
        try {
            trees = generate_move_trees(pgnParser.parse(pgn));
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
        let name = trees[i].headers.Event || i18n.translation_chapter + " " + (i+1);
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

function main() {
    setup_ground();
    setup_chess();
    setup_trees();
    setup_chapter_select();
    setup_move_handler(handle_move);

    window.total_moves = 0;

    resize_ground();

    set_text(info_div, i18n.info_intro);

    start_training();
}

window.onresize = resize_ground;
main();
