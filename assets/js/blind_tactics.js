require("regenerator-runtime/runtime"); // required for sleep (https://github.com/babel/babel/issues/9849#issuecomment-487040428)

const Chessground = require('chessground').Chessground;
const Chess = require('chess.js')
import { ground_init_state, resize_ground, setup_ground, ground_set_moves, 
         ground_undo_last_move, setup_move_handler, ground_move } from './modules/ground.js';
import { turn_color, setup_chess, from_to_to_san, san_to_from_to } from './modules/chess_utils.js';
import { set_text, clear_all_text, success_div, info_div, error_div, suggestion_div } from './modules/info_boxes.js';
import { sleep } from './modules/sleep.js';

function show_div(id) {
    document.getElementById(id).classList.remove("hidden");
}

async function handle_move(orig, dest, extraInfo) {
}

/*
 * Dirty hack? Load the required values from a hidden form field.
 * The values of the hidden form field is changed by the push_redirect
 * First this was done inside of a script but the script would not get
 * re-evaluated by the browser resulting in old values being used.
 */
function load_data() {
    pgn = document.getElementById("pgn").value;
    color = document.getElementById("color").value;
    ply = document.getElementById("ply").value;
}

function main() {
    load_data();
    resize_ground();
    setup_move_handler(handle_move);
}

document.addEventListener("phx:update", main);
window.onresize = resize_ground;
window.old_pgn = "abc";
main();
