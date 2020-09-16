require("regenerator-runtime/runtime"); // required for sleep (https://github.com/babel/babel/issues/9849#issuecomment-487040428)

const Chessground = require('chessground').Chessground;
const Chess = require('chess.js')
const Stockfish = require('stockfish.wasm');

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

async function handle_move(orig, dest) {
    get_ai_move();
    setup_move();
}

function setup_move() {
    ground_set_moves();
}

function get_ai_move() {
    console.log("get_ai_move")
    Stockfish().then(sf => {
        console.log("then")
        sf.addMessageListener(line => {
            console.log(line);
        });
        console.log("postMessge uci")
        sf.postMessage('uci');
    });
}

function main() {
    let regex = /%20/g
    let fen = document.location.hash.split("#")[1].replace(regex, " ");
    setup_chess(fen);
    window.color = turn_color(chess);
    setup_ground(fen);
    resize_ground();
    setup_move_handler(handle_move);
    setup_move();
}

window.onresize = resize_ground;
main();
