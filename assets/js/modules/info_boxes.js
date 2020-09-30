const success_div = "success";
const error_div = "error";
const info_div = "info";
const suggestion_div = "suggestion";

function clear_all_text() {
    set_text(error_div, "");
    set_text(info_div, "");
    set_text(success_div, "");
    set_text(suggestion_div, "");
}

function set_text(id, text) {
    let div = document.getElementById(id);
    if (div == null) {
        return;
    }
    if (text.length > 0) {
        div.classList.remove("hidden");
        switch (id) {
            case success_div:
                text = "✓ " + text;
                break;
            case info_div:
                text = "🛈 " + text;
                break;
            case error_div:
                text = "✕ " + text;
                break;
            default:
                break;
        }
    } else {
        div.classList.add("hidden");
    }

    // This function can (and will be) be called with untrusted 
    // text from the pgn, therefore use textContent 
    // to keep this function save from XSS attacks
    // https://cheatsheetseries.owasp.org/cheatsheets/DOM_based_XSS_Prevention_Cheat_Sheet.html#rule-6-populate-the-dom-using-safe-javascript-functions-or-properties
    div.textContent = text; 
}

export { set_text, clear_all_text, success_div, info_div, error_div, suggestion_div };
