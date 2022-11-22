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

function set_multiple_texts(container_id, texts) {
    let container_div = document.getElementById(container_id);
    container_div.innerHTML = '';
    for (let [i, text] of texts.entries()) {
        var comment_div = document.createElement('div');
        comment_div.id = 'comment' + i;
        var comment_text_div = document.createElement('div');
        comment_text_div.id = comment_div.id + "_text"
        comment_div.appendChild(comment_text_div);
        container_div.appendChild(comment_div);
        set_text(comment_div.id, text);
    }
}

function set_text(id, text, extra = { bold_text: "", symbol: "" }) {
    let div = document.getElementById(id);
    let prefix_symbol = "";
    if (div == null) {
        return;
    }
    if (text.length > 0) {
        div.classList.remove("hidden");
        switch (id) {
            case success_div:
                prefix_symbol = "✓";
                break;
            case info_div:
                prefix_symbol = "🛈"
                break;
            case error_div:
                prefix_symbol = "✕"
                break;
            default:
                break;
        }
        if (extra.symbol != undefined && extra.symbol != "") {
            prefix_symbol = extra.symbol;
        }
    } else {
        div.classList.add("hidden");
    }

    // This function can (and will be) be called with untrusted 
    // text from the pgn, therefore use textContent 
    // to keep this function save from XSS attacks
    // https://cheatsheetseries.owasp.org/cheatsheets/DOM_based_XSS_Prevention_Cheat_Sheet.html#rule-6-populate-the-dom-using-safe-javascript-functions-or-properties
    set_text_content(id + "_text", text);
    set_text_content(id + "_symbol", prefix_symbol);
    set_text_content(id + "_bold", extra.bold);
}

function set_text_content(id, content) {
    let element = document.getElementById(id);
    if (element != null) {
        element.textContent = content;
    }
}

export { set_text, set_multiple_texts, clear_all_text, success_div, info_div, error_div, suggestion_div };
