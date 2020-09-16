const Chessground = require('chessground').Chessground;
import { ground_legal_moves } from './chess_utils';

/*
 * All the functions assume there is a global variable
 * ground that contains the chessground
 */

function ground_init_state(fen) {
    const config = {};
    config["orientation"] = color;
    config["movable"] = { free: false, showDests: true };
    // fen for the initial position
    config["fen"] = fen;
    config["highlight"] = { check: true };
    config["lastMove"] = undefined;
    config["drawable"] = {brushes: {hint: {key: "v", color: "#0034FF", opacity: 1, lineWidth: 10 }}}
    ground.set(config);
}

function setup_move_handler(f) {
    ground.set({movable: {events: {after: f}}});
}

function setup_click_handler(f) {
    ground.set({events: {select: f}});
}


// setsup the basic ground
function setup_ground(fen) {
    const config = {};
    window.ground = Chessground(document.getElementById("chessground"), config);
    ground_init_state(fen);
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

/*
 * Same as ground_set_moves but takes an instance of chess instead of the global one
 */
function ground_set_moves_from_instance(c) {
    let moves = ground_legal_moves(c);
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

/*
 * Returns the square the captured pawn is located
 * based on the chess.js moves object
 */
function en_passant_square(move) {
    let square = move.to.split("");
    if (move.color == "w") {
        square[1] = Number(square[1]) - 1;
    } else {
        square[1] = Number(square[1]) + 1;
    }
    return square.join("");
}

/*
 * Remove any piece from a square in san notation
 * e.g. empty_square("e4") removes the piece on e4
 */
function empty_square(square) {
    let m = new Object();
    m[square] = null;
    ground.setPieces(m);
}

/*
 * Expands the strings chess.js uses for pieces and colors
 * to the strings chessground uses
 */
function expand_chess_js_types(s) {
    switch(s) {
        case "b":
            return "black";
        case "w":
            return "white";
        case "p":
            return "pawn";
        case "r":
            return "rook";
        case "b":
            return "bishop";
        case "n":
            return "knight";
        case "q":
            return "queen";
        case "k":
            return "king";
    }
}

/*
 * Convert chess.js turn string to chessground turn string
 */
function cjs_turn(color) {
    if (color == "w") {
        return "white";
    } else {
        return "black";
    }
}

// move based on a chess.js move
function ground_move(m, c = undefined) {
    ground.move(m.from, m.to);
    if (c != undefined) {
        let in_check = c.in_check();
        ground.set({turnColor: cjs_turn(c.turn())})
        ground.set({check: in_check})
    }
    if (m.flags == "e") { // handle en passant
        let captured = en_passant_square(m)
        empty_square(captured);
    }
    if (m.flags.indexOf("p") !== -1) { // handle promotion
        let promoted_piece = expand_chess_js_types(m.promotion);
        let color = expand_chess_js_types(m.color);
        let square = m.to;
        let map = new Map();
        map.set(square, {role: promoted_piece, color: color});
        ground.setPieces(map);
    }
}

export { ground_init_state, resize_ground, setup_ground, ground_set_moves, ground_set_moves_from_instance, ground_undo_last_move, setup_move_handler, setup_click_handler, ground_move };
