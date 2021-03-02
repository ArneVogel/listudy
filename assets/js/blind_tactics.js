require("regenerator-runtime/runtime"); // required for sleep (https://github.com/babel/babel/issues/9849#issuecomment-487040428)

const Chessground = require('chessground').Chessground;
const Chess = require('chess.js')
import { resize_ground, setup_ground, ground_set_moves_from_instance, 
         ground_undo_last_move, setup_click_handler, ground_move } from './modules/ground.js';
import { ground_legal_moves, turn_color, setup_chess, uci_to_san, san_to_uci } from './modules/chess_utils.js';
import { set_text, clear_all_text, success_div, info_div, error_div, suggestion_div } from './modules/info_boxes.js';
import { sleep } from './modules/sleep.js';

function show_div(id) {
    document.getElementById(id).classList.remove("hidden");
}

function get_current_chess() {
    let tc = (typeof current_chess == 'undefined') ? new Chess() : current_chess;
    let moves_played = tc.history().length
    for (let i = moves_played; i < current_move; ++i) {
        let m = chess.history()[i];
        tc.move(m);
    }
    return tc;
}

function highlight_moves(square) {
    highlighted_squares = legal_moves.get(square);
    window.clicked_piece = square;

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

function piece_pos() {
    return chess.history({verbose: true})[current_move].from;
}

function set_div_text(id, text) {
    clear_all_text();
    set_text(id, text);
}


function handle_click(square) {
    ground.selectSquare(null);
    if (square == target() && clicked_piece == piece_pos()) {
        // has to be manually reset because highlight_moves is not called in this branch
        highlighted_squares = []; 
        current_move += 2;
        current_chess = get_current_chess();
        if (current_move >= chess.history().length) {
            let total = localStorage.getItem("achievements_blind_tactics_solved");
            localStorage.setItem("achievements_blind_tactics_solved", Number(total) + 1);

            set_div_text(success_div, i18n.success)
            document.getElementById("next").classList.remove("hidden");
            setup_ground(chess.fen());    
            let t = chess.turn() == "w" ? "white" : "black";
            // "check: true" would sometimes result in the wrong king being shown in check
            ground.set({check: t});
        } else {
            let last_move = current_chess.history().pop();
            set_div_text(info_div, i18n.right_move + last_move)
        }
        legal_moves = ground_legal_moves(current_chess);
    } else {
        if (highlighted_squares.indexOf(square) != -1) {
            set_div_text(error_div, i18n.wrong_move)
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

    const chess = new Chess();
    window.chess = chess;
    chess.load_pgn(pgn);

    // we cant hide more moves than there were. If chess.history().length is smaller
    // then the position starts with the starting position
    ply = Math.min(document.getElementById("ply").value, chess.history().length);
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

// the moves that were played from the base position to the current ply
function played_from_base() {
    return chess.history().slice(ply - hidden_moves,current_move);
}

// the fen of the position that is initially shown on the board
function base_fen() {
    let tc = new Chess();
    for (let m of chess.history().slice(0, ply - hidden_moves)) {
        tc.move(m);
    }
    return tc.fen();
}

// generates the pgn of the moves that were played from the base position
function setup_move_text() {
    let moves = played_from_base();
    let tc = new Chess(base_fen());

    for (let m of moves) {
        tc.move(m);
    }

    let pgn = tc.pgn();
    pgn = pgn.split("\n");
    pgn = pgn[pgn.length-1];

    document.getElementById("moves").innerText = pgn;
}

function main() {
    setup_ply();
    load_data();

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
