const Chessground = require('chessground').Chessground;
import { ground_legal_moves } from './chess_utils';
import { sounds } from './sounds.js';

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
    config["drawable"] = {brushes: {
        // normal: {key: "n", color: "#001a80", opacity: 1, lineWidth: 10 },
        // transparent: {key: "t", color: "#001a80", opacity: 0.5, lineWidth: 10 },
        // thin_normal: {key: "tn", color: "#000033", opacity: 1, lineWidth: 7 },  // #001a80 #000080 #000033
        // thin_transparent: {key: "tt", color: "#000033", opacity: 0.5, lineWidth: 7 },
        // green: {key: "g", color: "#00802b", opacity: 0.8, lineWidth: 10 },
        // blue: {key: "b", color: "#3333ff", opacity: 0.8, lineWidth: 10 },
        // red: {key: "r", color: "#ff0000", opacity: 0.8, lineWidth: 10 },
        // yellow: {key: "y", color: "#ffcc00", opacity: 0.85, lineWidth: 10 },
        // thick_green: {key: "tg", color: "#00802b", opacity: 0.7, lineWidth: 13 },
        // thick_blue: {key: "tb", color: "#3333ff", opacity: 0.7, lineWidth: 13 },
        // thick_red: {key: "tr", color: "#ff0000", opacity: 0.7, lineWidth: 13 },
        // thick_yellow: {key: "ty", color: "#ffcc00", opacity: 0.9, lineWidth: 13 }

        normal: {key: "n", color: "#3333ff", opacity: 0.6, lineWidth: 10 },
        transparent: {key: "t", color: "#3333ff", opacity: 0.3, lineWidth: 10 },
        thin_normal: {key: "tn", color: "#000000", opacity: 0.6, lineWidth: 12 },  // #001a80 #000080 #000033
        thin_transparent: {key: "tt", color: "#000000", opacity: 0.3, lineWidth: 12 },
        // 
        green:  {key: "g", color: "hsl(120, 100%, 25%)", opacity: 0.6,  lineWidth: 10 },
        blue:   {key: "b", color: "hsl(216, 100%, 60%)", opacity: 0.6,  lineWidth: 10 },
        red:    {key: "r", color: "hsl(0, 100%, 50%)",   opacity: 0.6,  lineWidth: 10 },
        yellow: {key: "y", color: "hsl(48, 100%, 45%)",  opacity: 0.65, lineWidth: 10 },
        // 
        decorate_pgn_green:  {key: "decorate_green",  color: "hsl(120, 100%, 27%)", opacity: 0.4,  lineWidth: 10 },
        decorate_pgn_blue:   {key: "decorate_blue",   color: "hsl(216, 100%, 35%)", opacity: 0.4,  lineWidth: 10 },
        decorate_pgn_red:    {key: "decorate_red",    color: "hsl(0, 100%, 55%)",   opacity: 0.4,  lineWidth: 10 },
        decorate_pgn_yellow: {key: "decorate_yellow", color: "hsl(48, 100%, 45%)",  opacity: 0.45, lineWidth: 10 },
        // 
        playable_pgn_normal_green:  {key: "playable_normal_green",  color: "hsl(120, 100%, 20%)", opacity: 0.9,  lineWidth: 9 },
        playable_pgn_normal_blue:   {key: "playable_normal_blue",   color: "hsl(216, 100%, 45%)", opacity: 0.9,  lineWidth: 9 },
        playable_pgn_normal_red:    {key: "playable_normal_red",    color: "hsl(0, 100%, 60%)",   opacity: 0.9,  lineWidth: 9 },
        playable_pgn_normal_yellow: {key: "playable_normal_yellow", color: "hsl(48, 100%, 45%)",  opacity: 0.9, lineWidth: 9 },
        // 
        playable_pgn_transparent_green:  {key: "playable_transparent_green",  color: "hsl(120, 100%, 30%)", opacity: 0.9,  lineWidth: 9 },
        playable_pgn_transparent_blue:   {key: "playable_transparent_blue",   color: "hsl(216, 100%, 55%)", opacity: 0.9,  lineWidth: 9 },
        playable_pgn_transparent_red:    {key: "playable_transparent_red",    color: "hsl(0, 100%, 60%)",   opacity: 0.9,  lineWidth: 9 },
        playable_pgn_transparent_yellow: {key: "playable_transparent_yellow", color: "hsl(48, 100%, 55%)",  opacity: 0.9, lineWidth: 9 }
    }};
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
    window.window_width = window.innerWidth;
    ground_init_state(fen);
}

/*
 * Window resize callback
 */
function onresize() {
    // Don't resize ground if the window width is unchanged
    if (window.innerWidth === window.window_width) {
        return;
    }

    window.window_width = window.innerWidth;
    resize_ground();
}

// call on window resizing
function resize_ground() {
    let gc = document.getElementById("game_container");
    let gc_width = gc.offsetWidth;
    let width = gc_width - 7; // for the numbers on the side of the ground
    width -= width % 8; // fix chrome alignment errors; https://github.com/ornicar/lila/pull/3881
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
    let map = new Map();
    map.set(square, null);
    ground.setPieces(map);
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

function play_sound(move) {
    let flags = move.flags;
    // clone the sound so it can be repeated in quick succession
    if (flags.indexOf("c") !== -1 || flags.indexOf("e") !== -1) {
        sounds.play("capture");
    } else {
        sounds.play("move");
    }
}

// move based on a chess.js move
function ground_move(m, c = undefined) {
    play_sound(m);
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

export { ground_init_state, onresize, resize_ground, setup_ground, ground_set_moves, ground_set_moves_from_instance, ground_undo_last_move, setup_move_handler, setup_click_handler, ground_move };
