import {Node, Tree} from './tree.js';

/*
 * Access for functions are arrays containing the 
 * indexes that have to be taken to reach the node
 * that correspond to the access array
 * e.g. [0,1,0] means take the first tree
 * from that tree take the 2nd first move
 * and from that move take the child
 */

/* Returns the children (possible replies to a move)
 * specified by the access array
 */
function tree_children(access) {
    if (access.length == 0) {
        return undefined;
    }
    let tree = trees[access[0]].root;
    if (access.length == 1) {
        return tree;
    }
    for (let a of access.slice(1)) {
        tree = tree[a].children;
    }
    return tree;
}

function tree_children_filter_sort(access, {filter=function(){return true;},sort=function(){return -1;}}={
    filter:function(){return true;},
    sort:function(){return -1;}
    } ) {
    return tree_children(access).filter(filter).sort(sort);
}

/*
 * Returns the possible replies to a move specified
 * by the access array in SAN notation (Ne6)
 *
 * optionally pass a function to filter the possible moves
 * e.g. has_children to ai moves that leave the player a reply
 */
function tree_possible_moves(access, {filter=function(){return true;},sort=function(){return -1;}}={
    filter:function(){return true;},
    sort:function(){return -1;}
    } ) {
    let children = tree_children_filter_sort(access, {filter:filter, sort:sort});
    let moves = [];
    for (let c of children) {
        moves.push(c.move);
    }
    return moves;
}

/*
 * Returns the index of the child whos move is equal to the san
 */
function tree_move_index(access, san) {
    let children = tree_children(access);
    for (let i = 0; i < children.length; ++i) {
        if (children[i].move == san) {
            return i;
        }
    }
    return -1;
}

/*
 * Sets value of a node to 0 if value is zero,
 * otherwise add the value to the current value
 */
function update_node_value(node, value) {
    node.updated = Date.now();
    if(value == 0) {
        node.value = 0;
    } else {
        node.value = Math.min(5, node.value + value);
    }
}

/*
 * Updates the node value for either all child nodes of the move
 * specified by access, or of a specific value if san is specified
 */
function update_value(access, value, san) {
    let children = tree_children(access);
    if (san !== undefined) {
        let i = tree_move_index(access,san);
        update_node_value(children[i], value);
    } else {
        for (let c of children) {
            update_node_value(c, value);
        }
    }
}

/*
 * Get the current node specified by access
 */
function tree_get_node(access) {
    if (access.length == 0) {
        return undefined;
    }
    let tree = trees[access[0]];
    if (access.length == 1) {
        return tree;
    }
    tree = tree.root;
    for (let a of access.slice(1).slice(0, -1)) {
        tree = tree[a].children;
    }
    tree = tree[access[access.length-1]];
    return tree;
}

/*
 * Can be used for tree_possible_moves to specify 
 * only moves that have a reply
 */
function has_children(node) {
    return node.children.length != 0;
}

/*
 * Checks if there is a child with childs
 */
function has_grandchildren(node) {
    if (node.children.length == 0) {
        return false;
    }
    for (let c of node.children) {
        if (c.children.length != 0) {
            return true;
        }
    }
    return false;
}


/*
 * Moves that have a lower than the threshold for training
 */
function need_hint(node) {
    return node.value < 2;
}

/*
 * Sorts nodes by date 
 */
function date_sort(a,b) {
    a = a.updated;
    b = b.updated;
    if (a < b) {
        return -1;
    } else if (a > b) {
        return 1;
    }
    return 0;
}

/*
 * Sorts nodes by tree value
 */
function value_sort(a,b) {
    /*
     * We have to filter by has_grandchildren because otherwise leafes
     * with moves by the ai without children which are never updates
     * will always result in a return of 0 for the subtree containing it.
     */
    let av = tree_value(a, Math.min, {filter:has_grandchildren});
    let bv = tree_value(b, Math.min, {filter:has_grandchildren});
    if (av < bv) {
        return -1;
    } else if (av > bv) {
        return 1;
    }
    return date_sort(a,b);
}



/*
 * Returns the min or max value of a tree
 * tree is a pgn sub tree
 * minmax is either Math.max or Math.min
 */
function tree_value(tree, minmax, {filter=function(){return true;}}={
    filter:function(){return true;}
    }) {
    let curr_value = tree.value;
    let child_values = tree.children.filter(filter).map(x => tree_value(x, minmax, {filter:filter}));
    let minmax_children = minmax(...child_values);
    return minmax(curr_value, minmax_children);
}

/*
 * Returns the sum of the values of the tree as well as the maximum possible value
 */
function tree_progress(tree) {
    let value = parseInt(tree.value);
    if (tree.children.length == 0) {
        return [value, 5];
    }
    let child_values = tree.children.map(x => tree_progress(x));
    let sum = [value, 5];
    for (let c of child_values) {
        sum[0] += c[0];
        sum[1] += c[1];

    }
    return sum;
}


export { tree_progress, tree_children, tree_children_filter_sort, tree_possible_moves, tree_move_index, has_children, need_hint, update_value, date_sort, value_sort, tree_get_node, tree_value };
