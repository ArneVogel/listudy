document.addEventListener('DOMContentLoaded', function () {
    let background_localStorageKey = "chessground_background";
    let background_selectorId = "chessboard_background";
    let bg_selector = document.getElementById(background_selectorId);
    let chessboard_background = localStorage.getItem(background_localStorageKey) || "blue";
    bg_selector.value = chessboard_background;
    bg_selector.onchange = function() {
        let new_background = document.getElementById(background_selectorId).value;
        let old_background = localStorage.getItem(background_localStorageKey) || "blue";
        localStorage.setItem(background_localStorageKey, new_background);
        document.documentElement.classList.remove(old_background);
        document.documentElement.classList.add(new_background);
    }
    let piece_localStorageKey = "chessground_piece";
    let piece_selectorId = "chessboard_pieces";
    let piece_selector = document.getElementById(piece_selectorId);
    let chessboard_piece = localStorage.getItem(piece_localStorageKey) || "cburnett";
    piece_selector.value = chessboard_piece;
    piece_selector.onchange = function() {
        let new_piece = document.getElementById(piece_selectorId).value;
        let old_piece = localStorage.getItem(piece_localStorageKey) || "cburnett";
        localStorage.setItem(piece_localStorageKey, new_piece);
        document.documentElement.classList.remove(old_piece);
        document.documentElement.classList.add(new_piece);
    }

});
