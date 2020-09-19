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

async function handle_move(orig, dest) {
    move(orig, dest);
    ai_move();

}

function move(orig,dest) {
    let san = uci_to_san(chess, orig, dest);
    let m = chess.move(san);
    ground_set_moves();
    ground_move(m,chess);
}

function ai_move() {
    sf.postMessage('uci');
    sf.postMessage('ucinewgame');
    sf.postMessage(`position fen ${chess.fen()}`);
    sf.postMessage('go movetime 1000');
}

function main() {
    let hash = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1;p";
    if (document.location.hash != "") {
        let regex = /%20/g
        hash = document.location.hash.split("#")[1].replace(regex, " ");
    }
    let hash_splits = hash.split(";")
    let fen = hash_splits[0];
    if (!fen.endsWith("0 1")) {
        // Add 0 1 to fens like 
        // rnbqk2r/ppp1ppbp/3p1np1/8/3P4/3BPN2/PPP2PPP/RNBQK2R w KQkq -
        // Otherwise chess.js wont parse the fen correctly
        fen = `${fen} 0 1`;
    }
    let first_move = hash_splits[1] || "p";

    setup_chess(fen);
    window.color = turn_color(chess);
    if (first_move == "sf") {
        // switch the board rotation for the player to be bottom
        color = color == "white" ? "black" : "white";
    }
    setup_ground(fen);
    resize_ground();
    setup_move_handler(handle_move);
    ground_set_moves();

    Stockfish().then(sf => {
        window.sf = sf;
        sf.addMessageListener(line => {
            if(line.startsWith("bestmove")) {
                let orig = line.substring(9,11);
                let dest = line.substring(11,13);
                move(orig, dest);
            }
        });

        if (first_move == "sf") {
            ai_move();
        }
    });
}

window.onresize = resize_ground;
main();
