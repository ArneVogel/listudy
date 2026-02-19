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

/**
 * Gets an option by key from local storage. Also verifies the key is one of the allowed values
 * in case the code has changed since the user used the app last time. In such case it falls back
 * on the default value.
 *
 * Pass a validate function to provide custom validation of the read value from local storage.
 * Pass a transform function to provide custom transformation of the value, such as convering to a number etc.
 */
function get_option_from_localstorage(key, default_value, allowed_values = undefined, {validate=function(){return true;},transform=function(f){return f;}}={
    validate:function(){return true;},
    transform:function(f){return f;}
} ) {

    let ls_value = localStorage.getItem(key);
    let is_allowed_value = allowed_values == undefined || allowed_values.indexOf(ls_value) >= 0;
    let transformed_value = transform(ls_value);
    if (transformed_value && is_allowed_value && validate(transformed_value)) {
        return transformed_value;
    } else {
        return default_value;
    }
}

export { clear_local_storage, get_option_from_localstorage };
