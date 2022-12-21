const Chessground = require('chessground').Chessground;
import { ground_legal_moves, cal_to_ftc, san_to_uci } from './chess_utils';
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
        normal: {key: "n", color: "#3333ff", opacity: 0.6, lineWidth: 10 },
        transparent: {key: "t", color: "#3333ff", opacity: 0.3, lineWidth: 10 },
        // 
        pgn_green:  {key: "pgn_green",  color: "hsl(120, 100%, 27%)", opacity: 0.35, lineWidth: 10 },
        pgn_blue:   {key: "pgn_blue",   color: "hsl(216, 100%, 35%)", opacity: 0.35, lineWidth: 10 },
        pgn_red:    {key: "pgn_red",    color: "hsl(0, 100%, 55%)",   opacity: 0.35, lineWidth: 10 },
        pgn_yellow: {key: "pgn_yellow", color: "hsl(48, 100%, 45%)",  opacity: 0.40, lineWidth: 10 },
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
    window.overlay_manager.on_resize();
}

/*
 * Returns the width the chessground should have as integer
 */
function calculate_width() {
    let gc = document.getElementById("game_container");
    let gc_width = gc.offsetWidth;
    let width = gc_width - 7; // for the numbers on the side of the ground
    width -= width % 8; // fix chrome alignment errors; https://github.com/ornicar/lila/pull/3881
    return width;
}

// call on window resizing
function resize_ground() {
    let width_integer = calculate_width();
    let width = "" + width_integer + "px";
    let chessground = document.getElementById("chessground");
    chessground.style.width = width;
    chessground.style.height = width;
    ground.redrawAll();
}

function create_arrow_from_move(move, brush) {
    let ft = san_to_uci(chess, move);
    return {orig: ft.from, dest: ft.to, brush: brush};
}

/**
 * Create an arrow that represents a pure PGN arrow, that is not playable, but only exists as an arrow
 * in the PGN file.
 * @param  cal  The cal value (ie "Gd2d4" for a Green d2 -> d4 arrow).
 */
function create_pgn_arrow(cal) {
    let ftc = cal_to_ftc(cal)
    let brush = "pgn_" + ftc.color;
    return {orig: ftc.from, dest: ftc.to, brush: brush};
}

/**
 * Creates a circle from the PGN.
 * @param  csl  The csl value from the PGN file (ie Bd2 for a Blue circle on d2).
 */
function create_pgn_circle(csl) {
    let ftc = cal_to_ftc(csl)
    let brush = "pgn_" + ftc.color;
    return {orig: ftc.from, brush: brush};
}

const TextOverlayDuration = {
    OneMove: "OneMove",
}
const TextOverlayType = {
    INFO: "TextOverlayInfo",
}

class TextOverlay {
    contains(options, find) {
        for (let key in Object.keys(options)) {
            if (TextOverlayType[key] == find) {
                return 0;
            }
        }
        return -1;
    }
    clean_text(text) {
        return text.replace(/ /gi, "-");
    }
    id() {
        return `${this.position}${this.clean_text(this.text)}`;
    }
    fen_to_index(position) {
        let [row, rank] = position.split(""); // "e4" => "e" "4"
        rank = parseInt(rank);
        let m = {a: 1,
                 b: 2,
                 c: 3,
                 d: 4,
                 e: 5,
                 f: 6,
                 g: 7,
                 h: 8};
        row = m[row];
        return [row, rank];
    }
    constructor(text, position, type, duration) {
        this.text = text;
        if (!this.contains(TextOverlayDuration, duration)) {
            console.error("TextOverlayDuration is not defined: ", duration);
        }
        this.duration = duration;
        if (!this.contains(TextOverlayType, type)) {
            console.error("TextOverlayType is not defined: ", type);
        }
        this.type = type;
        this.position = position;

        this.elem = this.create();
        this.resize();
    }

    create() {
        let span = document.createElement("span");
        span.id = this.id();
        span.innerText = this.text;
        span.classList.add("TextOverlay");
        span.classList.add(this.type);

        let container = document.getElementById("game_container");
        container.appendChild(span);
        return span;
    }

    resize() {
        let [row, rank] = this.fen_to_index(this.position);
        let cell_width = calculate_width() / 8;
        let left = cell_width * (row - 1);
        let top = cell_width * (8-rank);
        left += cell_width * 0.5;
        top += cell_width * 0.5;
        this.elem.style.left = "" + left + "px";
        this.elem.style.top = "" + top + "px";
    }

    remove() {
        let id = this.id();
        document.getElementById(id).remove();
    }
}

class TextOverlayManager {
    constructor() {
        this.overlays = [];
    }

    add_overlay(overlay) {
        this.overlays.push(overlay);
    }

    clear_overlays() {
        for (let overlay of this.overlays) {
            if (overlay.duration === TextOverlayDuration.OneMove) {
                overlay.remove();
            }
        }
        this.overlays = this.overlays.filter((x) => x.duration != TextOverlayDuration.OneMove);
    }

    on_resize() {
        for (let overlay of this.overlays) {
            overlay.resize();
        }
    }
}

function array_contains(arr, str) {
    return arr.indexOf(str) > -1;
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

/**
 * Checks whether a move is legal (after they have been set in chessground).
 */
function ground_is_legal_move(from, to) {
    let legal_moves = ground.state.movable.dests;
    if (legal_moves == undefined) {
        return true;
    }
    let dests = legal_moves.get(from) || [];
    let legal = array_contains(dests, to);
    return legal;
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

export { ground_init_state, onresize, resize_ground, setup_ground, ground_set_moves, ground_set_moves_from_instance, ground_undo_last_move, setup_move_handler, setup_click_handler, ground_move, TextOverlayDuration, TextOverlayType, TextOverlay, TextOverlayManager, ground_is_legal_move, create_arrow_from_move, create_pgn_arrow, create_pgn_circle };
