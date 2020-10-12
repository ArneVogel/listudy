function is_tree(key) {
    let s = key.split("_");
    if (s.length != 2) {
        return false;
    }

    return s[1] == "tree";
}

function tree_last_access(tree) {
    let dates = tree.map(x => x.root[0].updated);
    // console.log(Math.max(dates)) for some reason Math.max returns NaN so we do it by hand
    let max = 0;
    for (let d of dates) {
        if (d > max) {
            max = d;
        }
    }
    return max;
}

function compare_trees(a,b) {
    let tree_a = JSON.parse(localStorage.getItem(a));
    let tree_b = JSON.parse(localStorage.getItem(b));
    return tree_last_access(tree_b) - tree_last_access(tree_a);
}

function remove_tree(key) {
    let id = key.split("_")[0];
    let hash_key = id + "_hash";
    localStorage.removeItem(key);
    localStorage.removeItem(hash_key);
}

/*
 * Removes the oldest trees to make place for new trees
 */
function clear_local_storage() {
    const limit = 10;
    let tree_keys = Object.keys(localStorage).filter(is_tree);
    if (tree_keys.length < limit) {
        return;
    }
    tree_keys.sort(compare_trees);
    let to_remove = tree_keys.slice(limit);
    to_remove.forEach(remove_tree);
}

export { clear_local_storage };
