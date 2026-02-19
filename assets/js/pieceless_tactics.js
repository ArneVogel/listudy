require("regenerator-runtime/runtime"); // required for sleep (https://github.com/babel/babel/issues/9849#issuecomment-487040428)

const Chessground = require('chessground').Chessground;
const Chess = require('chess.js')
import { onresize, resize_ground, setup_ground, ground_set_moves,
         ground_undo_last_move, setup_move_handler, ground_move } from './modules/ground.js';
import { ground_legal_moves, turn_color, setup_chess, uci_to_san, san_to_uci } from './modules/chess_utils.js';
import { set_text, clear_all_text, success_div, info_div, error_div, suggestion_div } from './modules/info_boxes.js';
import { sleep } from './modules/sleep.js';

function show_history(chess) {
    // unhide the container
    // this is needed because "History:" is hidden this way before the first move is made
    document.getElementById("history_container").classList.remove("hidden");
    // this is the span inside of history_container
    let d = document.getElementById("history");
    let history = chess.history().join(" ");
    d.innerText = history;
}

function handle_move(orig, dest, extraInfo) {
    clear_all_text();
    let expected = solution[0];
    if (expected.startsWith(orig+dest)) {
        // we need more than three for this to continue so less means solved
        // [0] current (correct) move
        // [1] ai reply
        // [2] expected human move
        if (solution.length <= 2) {
            // play the move so show_history will be correct after the if else
            let played = uci_to_san(chess, orig, dest);
            chess.move(played);

            document.getElementById("next").classList.remove("hidden");
            set_text(success_div, i18n.solved);
        } else {
            // at least one more move is needed to solve this

            // play the human move
            let played = uci_to_san(chess, orig, dest);
            chess.move(played);
            solution = solution.slice(1); // remove the human move from the solution

            // make the ai move
            let ai_move = solution[0].match(/.{1,2}/g); // split "a2a4" into ["a2", "a4"]

            let move = {from: ai_move[0], to: ai_move[1]};
            if (ai_move.length == 3) {
                move.promotion = ai_move[2];

            }

            chess.move(move);
            solution = solution.slice(1); // remove the ai move from the solution

            // let me player know there are move moves needed
            set_text(success_div, i18n.right_move);
            ground_set_moves();
        }
        show_history(chess);
    } else {
        set_text(error_div, i18n.wrong_move);
        ground_undo_last_move(); 
        ground_set_moves();
    }
}

function num_to_file(num) {
    let to_return = "ERROR in num_to_file";
    num = Number(num);
    switch (num) {
        case 0: to_return = "a"; break; 
        case 1: to_return = "b"; break;
        case 2: to_return = "c"; break;
        case 3: to_return = "d"; break;
        case 4: to_return = "e"; break;
        case 5: to_return = "f"; break;
        case 6: to_return = "g"; break;
        case 7: to_return = "h"; break;
    }
    return to_return;
}

function expand_abbreviation(type) {
    let to_return = "ERROR in expand_abbreviation";

    switch (type) {
        case "k": to_return = "king"; break;
        case "q": to_return = "queen"; break;
        case "r": to_return = "rook"; break;
        case "n": to_return = "knight"; break;
        case "b": to_return = "bishop"; break;
        case "p": to_return = "pawn"; break;
    }
    return to_return;
}

function display_piece(piece) {
    let piece_color = piece.color == "w" ? "white" : "black";
    let piece_type = expand_abbreviation(piece.type);

    let d = document.createElement("div"); //container
    let p = document.createElement("piece"); //piece display
    let s = document.createElement("div"); //square of piece
    p.classList.add(piece_color);
    p.classList.add(piece_type);
    p.classList.add("chessground_piece"); // 45px width height and background size
    s.innerText = piece.square;
    s.classList.add("pieceless_piece_square");
    d.classList.add("pieceless_piece_container");
    d.appendChild(s);
    d.appendChild(p);
    document.getElementById("pieceless_pieces").appendChild(d);
}

function setup_pieces(chess) {
    let pieces = [];
    let board = chess.board();
    for (let rank in board) {
        for (let file in board[rank]) {
            if (board[rank][file] != null) {
                let r = Number(rank);
                let f = Number(file);
                f = num_to_file(f);
                r = 8-r;
                let piece = board[rank][file];
                piece.square = f+r;

                pieces.push(piece);
            }
        }
    }

    for (let piece of pieces) {
        display_piece(piece);
    }
}

function setup_to_play(chess) {
    let to_play = chess.turn() == "w" ? i18n.white : i18n.black;
    document.getElementById("pieceless_to_play").innerText = to_play;
}

function setup_give_up() {
    let e = document.getElementById("give-up");
    e.onclick = function() {
        document.getElementById("next").classList.remove("hidden");
    };
}

function main() {
    window.chess = new Chess(fen);
    setup_pieces(chess);
    setup_to_play(chess);
    window.color = chess.turn() == "w" ? "white" : "black";
    setup_ground(fen);

    ground_set_moves();

    window.highlighted_squares = [];

    setup_move_handler(handle_move);
    solution = solution.split(" ");

    resize_ground();
    window.setTimeout(ground.redrawAll, 10);
    window.setTimeout(ground.redrawAll, 100);
    setup_give_up();
}

window.onresize = onresize;
main();
