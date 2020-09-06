require("regenerator-runtime/runtime"); // required for sleep (https://github.com/babel/babel/issues/9849#issuecomment-487040428)

const Chessground = require('chessground').Chessground;
const Chess = require('chess.js')
import { resize_ground, setup_ground, ground_set_moves_from_instance, 
         ground_undo_last_move, setup_click_handler, ground_move } from './modules/ground.js';
import { ground_legal_moves, turn_color, setup_chess, from_to_to_san, san_to_from_to } from './modules/chess_utils.js';
import { set_text, clear_all_text, success_div, info_div, error_div, suggestion_div } from './modules/info_boxes.js';
import { sleep } from './modules/sleep.js';

function show_div(id) {
    document.getElementById(id).classList.remove("hidden");
}

function get_current_chess() {
    let tc = new Chess();
    for (let i = 0; i < current_move; ++i) {
        let m = chess.history()[i];
        tc.move(m);
    }
    return tc;
}

function highlight_moves(square) {
    highlighted_squares = legal_moves.get(square);

    if (highlighted_squares == undefined) {
        highlighted_squares = [];
        return;
    }

    let shapes = [];
    for (let s of highlighted_squares) {
        shapes.push({orig: s, brush: "green"});
    }
    ground.setShapes(shapes);
    ground.redrawAll(); 
}

function target() {
    return chess.history({verbose: true})[current_move].to;
}

function hide_all_div() {
    for (let d of ["success", "info", "error"]) {
        document.getElementById(d).classList.add("hidden");
    }
}

function set_div_text(id, text) {
    document.getElementById(id).classList.remove("hidden");
    document.getElementById(id).innerText = text;
}


function handle_click(square) {
    hide_all_div();
    ground.selectSquare(null);
    if (square == target()) {
        // has to be manually reset because highlight_moves is not called in this branch
        highlighted_squares = []; 
        current_move += 2;
        if (current_move >= chess.history().length) {
            set_div_text("success", i18n_success)
            document.getElementById("next").classList.remove("hidden");
            setup_ground(chess.fen());    
        } else {
            set_div_text("info", i18n_right_move)
        }
        current_chess = get_current_chess();
        legal_moves = ground_legal_moves(current_chess);
    } else {
        if (highlighted_squares.indexOf(square) != -1) {
            set_div_text("error", i18n_wrong_move)
        }
        highlight_moves(square);
    }

    setup_move_text();
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

function ply_change() {
    let p = document.getElementById("ply_select").value;
    window.hidden_moves = p;
    localStorage.setItem("blind_tactics_hidden", p);
}

function setup_ply() {
    let p = localStorage.getItem("blind_tactics_hidden") || 4;
    window.hidden_moves = p;
    document.getElementById("ply_select").value = p;
    document.getElementById("ply_select").addEventListener("change", ply_change);
}

/*
 * The position that should get displayed by the board
 * returns the fen of that position
 */
function get_base_position() {
    let tc = new Chess();
    for (let i = 0; i < ply - hidden_moves; ++i) {
        let m = chess.history()[i];
        tc.move(m);
    }
    return tc.fen();
}

function played_from_base() {
    return chess.history().slice(ply - hidden_moves,current_move);
}

function setup_move_text() {
    let m = played_from_base();
    document.getElementById("moves").innerText = m.join(" ");
}

function main() {
    load_data();
    setup_ply();
    const chess = new Chess();
    window.chess = chess;
    chess.load_pgn(pgn);


    if (pgn != old_pgn) {
        setup_ground(get_base_position());    
        old_pgn = pgn;
    }
    window.current_move = Number(ply);
    window.current_chess = get_current_chess();
    window.legal_moves = ground_legal_moves(current_chess);

    setup_move_text(); // display the hidden moves in text form

    window.highlighted_squares = [];

    setup_click_handler(handle_click);

    // fixes a bug of pieces getting stuck in the left corner of the board after
    // clicking on continue
    // https://www.reddit.com/r/chess/comments/in00we/introducing_blind_tactics/g44lpcz
    resize_ground();
    window.setTimeout(ground.redrawAll, 10);
    window.setTimeout(ground.redrawAll, 100);
}

document.addEventListener("phx:update", main);
window.onresize = resize_ground;
window.old_pgn = "abc";
main();
