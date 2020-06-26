/*
 * In this file functions with security concerns are defined
 * Use with care
 */

/*
 * Unescapes strings
 * the resultings string are only to be used by secure javascript functions
 */
function unescape_string(text) {
    let parser = new DOMParser;
    let dom = parser.parseFromString(
        '<!doctype html><body>' + text,
        'text/html');
    return dom.body.textContent;
}

export { unescape_string };
