const Chessground = require('chessground').Chessground;
const Chess = require('chess.js')
import { ground_init_state, resize_ground, setup_ground, ground_set_moves, 
         ground_undo_last_move, setup_move_handler } from './modules/ground.js';
import { turn_color, setup_chess, from_to_to_san, san_to_from_to } from './modules/chess_utils.js';

function handle_move(orig, dest, extraInfo) {
}

function main() {
    setup_ground(fen);    
    setup_chess(fen);
    resize_ground();
    ground_set_moves();
    setup_move_handler(handle_move);
}

document.addEventListener("phx:update", resize_ground);
window.onresize = resize_ground;
main();
