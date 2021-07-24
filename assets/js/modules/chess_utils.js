const Chess = require('chess.js')

function setup_chess(fen) {
    const chess = new Chess(fen)
    window.chess = chess;
}

function legal_moves_san(c) {
    return c.moves()
}

function legal_moves_uci(c) {
    let moves = [];
    for (let m of c.moves({verbose: true})) {
        moves.push({from: m.from, to: m.to});
    }
    return moves;
}

// the legal moves in the format that chessground can use
function ground_legal_moves(c) {
    let ft = legal_moves_uci(c);
    let moves = new Map();
    for (let m of ft) {
        if (!moves.has(m.from)) {
            moves.set(m.from, [m.to]);
        } else {
            let t = moves.get(m.from);
            t.push(m.to);
            moves.set(m.from, t);
        }
    }
    return moves;
}

/*
 * Convert moves in from to notation (b1 c3)
 * to SAN notation (Nc3) 
 * iff the move is legal in the chess position 
 */
function uci_to_san(chess, from, to) {
    let move = chess.move({from:from, to:to, promotion: 'q'});
    chess.undo();
    return move.san;
}

/*
 * Reverse of uci_to_san
 */
function san_to_uci(chess, san) {
    let move = chess.move(san);
    chess.undo();
    return {from: move.from, to: move.to};
}

/*
 * Convert the color string to the one used in the db
 */
function turn_color(chess) {
    let color = chess.turn();
    if (color == "b") {
        return "black";
    } else if (color == "w") {
        return "white"
    }
    // This should not happen!
    console.log("Chess.js;turn_color; Color is neither b nor w.")
    return "white";
}

function initial_fen(chess) {
    let pgn = chess.pgn();
    let fen = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1";
    try {
        fen = pgn.split("FEN")[1].split("\"")[1];
    } catch (error) {}
    return fen;
}
 
export { turn_color, san_to_uci, uci_to_san, setup_chess, ground_legal_moves, initial_fen };
