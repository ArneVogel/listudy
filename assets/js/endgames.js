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

function show_div(id) {
    document.getElementById(id).classList.remove("hidden");
}

function finish_success() {
    show_div("success");
    show_div("next");

    document.getElementById("todo").classList.add("hidden");

    let ls_key = "solved_endgames";
    let solves = JSON.parse(localStorage.getItem(ls_key)) || [];
    solves.push(id);
    localStorage.setItem(ls_key, JSON.stringify(solves));
}

function finish_error() {
    show_div("error");
    show_div("reset");
    document.getElementById("todo").classList.add("hidden");
}

async function handle_move(orig, dest) {
    move(orig, dest);
    let history = chess.history({verbose: true});
    let last_move = history[history.length -1];
    if (target_result == "w" && chess.in_checkmate()) {
        finish_success();
    } else if (target_result == "w" && chess.in_draw()) {
        finish_error();
    } else if (target_result == "d" && chess.in_draw()) {
        finish_success();
    } else if (target_result == "p" && last_move.flags.indexOf("p") != -1 ){
        finish_success();
    } else {
        ai_move();
    }
}

function move(orig,dest) {
    let san = uci_to_san(chess, orig, dest);
    let m = chess.move(san);
    ground_set_moves();
    ground_move(m,chess);
}

function animate_progress_bar(movetime, reason="") {
    document.getElementById("progress_reason").innerText = reason;
    let bar = document.getElementById("progress");
    bar.style.transitionDuration = `${movetime/1000}s`;
    bar.style.width = "100%";
    window.setTimeout(function() {
        let bar = document.getElementById("progress");
        bar.style.transitionDuration = "";
        bar.style.width = "0%";
        document.getElementById("progress_reason").innerText = "";
        document.getElementById("progress_container").classList.add("hidden");
    }, movetime);
}

function ai_move() {
    let movetime = 1000
    let threads = window.navigator.hardwareConcurrency || 1;
    sf.postMessage('uci');
    sf.postMessage('ucinewgame');
    sf.postMessage(`setoption name Threads value ${threads}`);
    sf.postMessage(`position fen ${chess.fen()}`);
    sf.postMessage(`go movetime ${movetime}`);
}

function setup_target() {
    let div = document.getElementById("target");
    if (target_result == "w") {
        div.innerText = "win";
    } else if (target_result == "d"){
        div.innerText = "draw";
    } else {
        div.innerText = "promote";
    }
}

function main() {
    setup_chess(fen);
    window.color = turn_color(chess);
    setup_ground(fen);
    resize_ground();
    setup_move_handler(handle_move);
    ground_set_moves();

    setup_target();

    animate_progress_bar(2000, "Loading Stockfish...")
    if (typeof sf == "undefined") {
        Stockfish().then(sf => {
            window.sf = sf;
            sf.addMessageListener(line => {
                if(line.startsWith("bestmove")) {
                    let orig = line.substring(9,11);
                    let dest = line.substring(11,13);
                    move(orig, dest);
                    if (chess.in_checkmate()) {
                        finish_error();
                    } else if (target_result == "d" && chess.in_draw()) {
                        finish_success();
                    } else if (chess.in_draw()){
                        finish_error();
                    }
                }
            });
        });
    }
    document.getElementById("reset").addEventListener("click", main);
    document.getElementById("error").classList.add("hidden");
    document.getElementById("reset").classList.add("hidden");
    document.getElementById("todo").classList.remove("hidden");
}

window.main = main;
window.onresize = resize_ground;
main();
