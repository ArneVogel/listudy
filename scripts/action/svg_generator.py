import chess, chess.svg, chess.pgn, sys, io, argparse

def generate_svg(args, board, last_move):
    c = {'square dark': '#8ca2ad', 'square light': '#dee3e6',
         'square dark lastmove': '#c3d888', 'square light lastmove': '#93b266'}
    orientation = chess.WHITE if args.orientation == "white" else chess.BLACK
    svg = chess.svg.board(board=board, coordinates=False, orientation=orientation, size=args.size, lastmove=last_move, colors=c)
    return svg

def save_svg(args, svg):
    with open(args.output, 'w') as f:
        f.write(svg)
   

def gen_from_fen(args):
    board = chess.Board(args.fen)
    last_move = chess.Move.from_uci(args.last_move)

    svg = generate_svg(args, board, last_move)
    save_svg(args, svg)


def gen_from_pgn(args):
    name = args.output
    pgn = io.StringIO(args.pgn)
    game = chess.pgn.read_game(pgn)

    board = chess.Board()
    last_move = chess.Move.null()

    for move in game.mainline_moves():
        last_move = move
        board.push(move)

    svg = generate_svg(args, board, last_move)
    save_svg(args, svg)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Board image generator')
    parser.add_argument("--output", required=True)
    parser.add_argument("--fen", default="")
    parser.add_argument("--pgn", default="")
    parser.add_argument("--orientation", default="white")
    parser.add_argument("--last-move", default="0000") # 0000 is the default null move
    parser.add_argument("--size", default=360)
    args = parser.parse_args()

    if (args.fen and args.pgn):
        parser.error("Can't use both fen and pgn")
    if not (args.fen or args.pgn):
        parser.error("Either fen or pgn is required")

    if (args.fen):
        gen_from_fen(args)
    if (args.pgn):
        gen_from_pgn(args)
