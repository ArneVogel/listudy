const Chess = require('chess.js')

function setup_chess() {
    const chess = new Chess()
    window.chess = chess;
}

function legal_moves_san(c) {
    return c.moves()
}

function legal_moves_from_to(c) {
    let moves = [];
    for (let m of c.moves()) {
        let move_result = c.move(m);
        moves.push({from: move_result.from, to: move_result.to});
        c.undo();
    }
    return moves;
}

// the legal moves in the format that chessground can use
function ground_legal_moves(c) {
    let ft = legal_moves_from_to(c);
    let moves = {};
    for (let m of ft) {
        if (moves[m.from] == undefined) {
            moves[m.from] = [m.to];
        } else {
            moves[m.from].push(m.to);
        }
    }
    return moves;
}

/*
 * Convert moves in from to notation (b1 c3)
 * to SAN notation (Nc3) 
 * iff the move is legal in the chess position 
 */
function from_to_to_san(chess, from, to) {
    let move = chess.move({from:from, to:to});
    chess.undo();
    return move.san;
}

/*
 * Reverse of from_to_to_san
 */
function san_to_from_to(chess, san) {
    let move = chess.move(san);
    chess.undo();
    return {from: move.from, to: move.to};
}
 
 
export { san_to_from_to, from_to_to_san, setup_chess, ground_legal_moves };
