import {Node, Tree} from './tree.js';

function createNode(move) {
    let node = new Node(move.move);
    node.comments = move.comments;
    node.updated = Date.now();
    
    return node;
}


// Takes a moveLine and creates nodes from it
function generateNodes(moveLine) {
    let nodes = []; // all the moves that are possible from the current move

    let root_node = createNode(moveLine[0]);
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
        for (let header of game.headers) {
            tree.headers[header.name] = header.value;
        }
        trees.push(tree);
    }
    return trees;
}

export { generate_move_trees };
