import chess, chess.svg, chess.pgn, sys, io

name = sys.argv[1]
pgn = io.StringIO(sys.argv[2])
game = chess.pgn.read_game(pgn)

board = chess.Board()
last_move = chess.Move.null()

for move in game.mainline_moves():
    last_move = move
    board.push(move)

c = {'square dark': '#8ca2ad', 'square light': '#dee3e6',
     'square dark lastmove': '#c3d888', 'square light lastmove': '#93b266'}
svg = chess.svg.board(board=board, coordinates=False, lastmove=last_move, colors=c)

with open(name, 'w') as f:
    f.write(svg)
