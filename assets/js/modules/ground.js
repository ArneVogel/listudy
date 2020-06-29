const Chessground = require('chessground').Chessground;
import { ground_legal_moves } from './chess_utils';

/*
 * All the functions assume there is a global variable
 * ground that contains the chessground
 */

function ground_init_state() {
    const config = {};
    config["orientation"] = color;
    config["movable"] = { free: false, showDests: true };
    // fen for the initial position
    config["fen"] = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1";
    config["lastMove"] = undefined;
    config["drawable"] = {brushes: {hint: {key: "v", color: "#0034FF", opacity: 1, lineWidth: 10 }}}
    ground.set(config);
}

// setsup the basic ground
function setup_ground() {
    const config = {};
    window.ground = Chessground(document.getElementById("chessground"), config);
    ground_init_state();
}

// call on window resizing
function resize_ground() {
    let gc = document.getElementById("game_container");
    let gc_width = gc.offsetWidth;
    let width = gc_width - 7; // for the numbers on the side of the ground
    width = "" + width + "px";
    let chessground = document.getElementById("chessground");
    chessground.style.width = width;
    chessground.style.height = width;
    ground.redrawAll();
}

// sets the legal moves that can be played in the current chess instance
function ground_set_moves() {
    let moves = ground_legal_moves(chess);
    ground.set({movable: {dests: moves}});
}

function ground_undo_last_move() {
    // there has to be a move to be undone
    if (!"lastMove" in ground.state) {
        return;
    }
    let lm = ground.state.lastMove;
    ground.move(lm[1], lm[0]);
    ground.set({"fen": chess.fen()});
}

export { ground_init_state, resize_ground, setup_ground, ground_set_moves, ground_undo_last_move };
