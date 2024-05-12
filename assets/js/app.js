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


import "./components/modal.js"
import "./components/sound_settings.js"
import "./components/achievements.js"
import "./components/hamburger.js"
import "./components/chessboard_settings.js"
import "./components/support.js"

let toggle = document.getElementById("toggle_dark_mode");
if (toggle != null) {
    toggle.onclick = function() {
        let theme = localStorage.getItem("data-theme") == "light" ? "dark" : "light";
        localStorage.setItem("data-theme", theme);
        document.documentElement.setAttribute('data-theme', theme);
    }
}
