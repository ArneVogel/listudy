// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import "../css/app.scss"


// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import deps with the dep name or local files with a relative path, for example:
//
//     import {Socket} from "phoenix"
//     import socket from "./socket"
//
import "phoenix_html"

document.getElementById("toggle_dark_mode").onclick = function() {
    let theme = localStorage.getItem("data-theme") == "light" ? "dark" : "light";
    localStorage.setItem("data-theme", theme);
    document.documentElement.setAttribute('data-theme', theme);
}

/*
 * Setup share links if an element with id "share" exists on the page
 */
function social_links() {
    let div = document.getElementById("share");
    if (div == undefined) {
        return;
    }
    let url = window.location.href;
    let sites = ["twitter", "reddit", "facebook"];
    let urls = [`https://twitter.com/intent/tweet?text=${url}`, `https://www.reddit.com/submit?url=${url}`, `https://www.facebook.com/sharer/sharer.php?u=${url}`];

    for (let i = 0; i < sites.length; ++i) {
        let button = document.createElement("button");
        button.textContent = translation_share_on + " " + sites[i];

        let link = document.createElement("a");
        link.href = urls[i];
        link.rel = "nofollow noopener noreferrer";
        link.appendChild(button);
        div.appendChild(link);
    }
}

const load = () => {
    social_links();
}

window.onload = load;
