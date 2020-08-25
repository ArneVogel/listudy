require("regenerator-runtime/runtime"); // required for sleep (https://github.com/babel/babel/issues/9849#issuecomment-487040428)

const Chessground = require('chessground').Chessground;
const Chess = require('chess.js')
import { ground_init_state, resize_ground, setup_ground, ground_set_moves, 
         ground_undo_last_move, setup_move_handler } from './modules/ground.js';
import { turn_color, setup_chess, from_to_to_san, san_to_from_to } from './modules/chess_utils.js';
import { set_text, clear_all_text, success_div, info_div, error_div, suggestion_div } from './modules/info_boxes.js';
import { sleep } from './modules/sleep.js';

function show_div(id) {
    document.getElementById(id).classList.remove("hidden");
}

async function handle_move(orig, dest, extraInfo) {
    let played = from_to_to_san(chess, orig, dest);
    let target = to_play.shift();
    clear_all_text();

    if (played == target) {
        chess.move(played);
        if (to_play.length >= 2) {
            // theres another move the player has to get correct
            await sleep(100); // instant play by the ai feels weird
            let ai_move = to_play.shift();
            let m = chess.move(ai_move);
            ground_set_moves();
            ground.move(m.from, m.to);
        } else {
            // player got the puzzle correct
            set_text(success_div, gettext_success);
            show_div("next");
        }
    } else {
        // player failed the puzzle
        await sleep(300); // instant play by the ai feels weird
        to_play.unshift(target);
        ground_undo_last_move(); 
        ground_set_moves();
        set_text(error_div, gettext_wrong_move);
        show_div("next");
        show_div("solution");
    }
}

function setup_last_move() {
    let orig = last_move.substring(0,2);
    let dest = last_move.substring(2,4);
    ground.state.lastMove = [orig, dest];
}

/*
 * Dirty hack? Load the required values from a hidden form field.
 * The values of the hidden form field is changed by the push_redirect
 * First this was done inside of a script but the script would not get
 * re-evaluated by the browser resulting in old values being used.
 */
function load_data() {
    fen = document.getElementById("fen").value;
    color = document.getElementById("color").value;
    moves = document.getElementById("moves").value;
    last_move = document.getElementById("last_move").value;
}

function main() {
    load_data();
    window.to_play = moves.split(" ");
    if (fen != old_fen) {
        // This is done to prevent flickering on the initial load of the
        // tactic. Without this setup_ground is called again after the
        // liveview has connected with the server since its changing the 
        // parent containing div of the chessground. With this check we
        // notice that the fen hasnt changed so we can continue using 
        // this ground
        setup_ground(fen);    
        old_fen = fen;
    }
    setup_last_move(); 
    setup_chess(fen);
    ground_set_moves();
    resize_ground();
    setup_move_handler(handle_move);
}

document.addEventListener("phx:update", main);
window.onresize = resize_ground;
window.old_fen = "abc";
main();
