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

    // Button to close the info box
    let div_close = div.querySelector(".close_button");
    if (div_close != undefined) {
        div_close.onclick = () => { div.classList.add("hidden") }
    }

    // This function can (and will be) be called with untrusted 
    // text from the pgn, therefore use textContent 
    // to keep this function save from XSS attacks
    // https://cheatsheetseries.owasp.org/cheatsheets/DOM_based_XSS_Prevention_Cheat_Sheet.html#rule-6-populate-the-dom-using-safe-javascript-functions-or-properties
    set_text_content(id + "_text", text);
    set_text_content(id + "_symbol", prefix_symbol);
    set_text_content(id + "_bold", extra.bold_text);
}

function set_text_content(id, content) {
    let element = document.getElementById(id);
    if (element != null) {
        element.textContent = content;
    }
}

export { set_text, clear_all_text, success_div, info_div, error_div, suggestion_div };
