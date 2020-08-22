require("regenerator-runtime/runtime"); // required for sleep (https://github.com/babel/babel/issues/9849#issuecomment-487040428)

const Chessground = require('chessground').Chessground;
const Chess = require('chess.js')
import { ground_init_state, resize_ground, setup_ground, ground_set_moves, 
         ground_undo_last_move, setup_move_handler } from './modules/ground.js';
import { turn_color, setup_chess, from_to_to_san, san_to_from_to } from './modules/chess_utils.js';
import { set_text, clear_all_text, success_div, info_div, error_div, suggestion_div } from './modules/info_boxes.js';
import { sleep } from './modules/sleep.js';

async function handle_move(orig, dest, extraInfo) {
    let played = from_to_to_san(chess, orig, dest);
    let target = to_play.shift();
    clear_all_text();

    if (played == target) {
        chess.move(played);
        if (to_play.length >= 2) {
            // theres another move the player has to get correct
            let ai_move = to_play.shift();
            let m = chess.move(ai_move);
            ground_set_moves();
            ground.move(m.from, m.to);
        } else {
            // player got the puzzle correct
            set_text(success_div, gettext_success);
        }
    } else {
        // player failed the puzzle
        await sleep(300); // instant play by the ai feels weird
        to_play.unshift(target);
        ground_undo_last_move(); 
        ground_set_moves();
        set_text(error_div, gettext_wrong_move);
    }
}

function setup_last_move() {
    ground.state.lastMove = last_move.split(" ");
}

function main() {
    window.to_play = moves.split(" ");
    setup_ground(fen);    
    setup_last_move(); 
    setup_chess(fen);
    ground_set_moves();
    resize_ground();
    setup_move_handler(handle_move);
}

document.addEventListener("phx:update", resize_ground);
window.onresize = resize_ground;
main();
