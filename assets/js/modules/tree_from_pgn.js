import {Node, Tree} from './tree.js';

function createNode(move) {
    // filter only valid san characters, remove !,?, etc.
    move.move = move.move.replace(/[^a-zA-Z0-9-+=#]/g, "");
    let node = new Node(move.move);
    node.comments = move.comments;
    node.updated = Date.now();

    return node;
}


// Takes a moveLine and creates nodes from it
function generateNodes(moveLine) {
    let nodes = []; // all the moves that are possible from the current move

    let root_node = createNode(moveLine[0]);
    root_node.move_index = moveLine[0].move_index;
    let leaf = root_node;
    nodes.push(root_node);

    // alternatives to the root node of moveLine
    if(moveLine[0].ravs) {
        for (let rav of moveLine[0].ravs) {
            for (let rav_node of generateNodes(rav.moves)) {
                nodes.push(rav_node)
            }
        }
    }

    for (let i = 1; i < moveLine.length; ++i) {
        let first_child = createNode(moveLine[i]);
        first_child.move_index = moveLine[i].move_index;
        let child_nodes = [first_child];
        // Same as above, but in this case the children are getting added
        // directly to the leaf
        // This step handles the recursion of the ravs that represent
        // multiple lines that could be taken
        // As the ravs are also moveLines the same function can be used
        // to generate the subtrees for the ravs
        if(moveLine[i].ravs) {
            for (let rav of moveLine[i].ravs) {
                for (let rav_node of generateNodes(rav.moves)) {
                    child_nodes.push(rav_node);
                }
            }
        }
        leaf.children = child_nodes;

        // advance the leaf, the leaf is the latest move that has been
        // completed from the moveLine
        leaf = first_child;
    }

    return nodes;
}

// creates a tree from a parsed pgn from
// https://github.com/kevinludwig/pgn-parser
function generate_move_trees(parsedPGN) {
    console.log("parsedPGN:", parsedPGN);
    let trees = []
    for (let game of parsedPGN) {
        if (game.moves.length == 0) {
            continue;
        }
        let tree = new Tree(0);
        tree.root = generateNodes(game.moves);
        tree.headers = {};
        tree.comments = game.comments;
        tree.first_variation = game.first_variation;
        for (let header of game.headers) {
            tree.headers[header.name] = header.value;
        }
        trees.push(tree);
    }
    return trees;
}


function annotate_pgn(pgn) {
    const go = function (moves, idx) {
      var var_index = -1;

      for (let i = 0; i < moves.length; ++i) {
        var thismove = moves[i];
        thismove.move_index = idx + i;
        if (thismove.ravs !== undefined && thismove.ravs.length > 0) {
          for (let ri = 0; ri < thismove.ravs.length; ++ri) {
            var thisrav = thismove.ravs[ri];
            if (thisrav.moves !== undefined && thisrav.moves.length > 0) {
              if (var_index == -1) {
                var_index = idx + i;
              }
              go(thisrav.moves, i + idx);
            }
          }
        }
      }
      return var_index;
    };
    for (let game of pgn) {
      const first_var = go(game.moves, 0);
      if (first_var >= 0) {
        game.first_variation = first_var;
      } else {
        game.first_variation = null;
      }
    }
  }


export { generate_move_trees, annotate_pgn };
