/*
 * Text overlays are "speech bubbles" that can be placed on the chessboard and are used to explain certain arrows etc.
 */
import { san_to_uci, cal_to_ftc } from './chess_utils.js';
import { calculate_width, ground_is_legal_move, some_moves_neglected, current_move_neglected } from './ground.js';
import { array_contains } from './utils.js';


const TextOverlayDuration = {
    OneMove: "OneMove",
}
const TextOverlayType = {
    INFO: "TextOverlayInfo",
}
const TextOverlayId = {
    FIRST_PLAYABLE_MOVE: "first_playable_move",
    FIRST_PGN_ARROW: "first_pgn_arrow",
    FIRST_NEGLECTED_MOVE: "first_neglected_move"
}

class TextOverlay {
    contains(options, find) {
        for (let key in Object.keys(options)) {
            if (TextOverlayType[key] == find) {
                return 0;
            }
        }
        return -1;
    }
    clean_text(text) {
        return text.replace(/ /gi, "-");
    }
    id() {
        return `${this.position}${this.clean_text(this.text)}`;
    }
    fen_to_index(position) {
        let [file, rank] = position.split(""); // "e4" => "e" "4"
        rank = parseInt(rank);
        let m = {a: 1,
                 b: 2,
                 c: 3,
                 d: 4,
                 e: 5,
                 f: 6,
                 g: 7,
                 h: 8};
        file = m[file];
        return [file, rank];
    }
    constructor(text, position, type, duration) {
        this.text = text;
        if (!this.contains(TextOverlayDuration, duration)) {
            console.error("TextOverlayDuration is not defined: ", duration);
        }
        this.duration = duration;
        if (!this.contains(TextOverlayType, type)) {
            console.error("TextOverlayType is not defined: ", type);
        }
        this.type = type;
        this.position = position;

        this.elem = this.create();
        this.resize();
    }

    create() {
        let span = document.createElement("span");
        span.id = this.id();
        span.innerText = this.text;
        span.classList.add("TextOverlay");
        span.classList.add(this.type);

        let container = document.getElementById("game_container");
        container.appendChild(span);
        return span;
    }

    resize() {
        let [file, rank] = this.fen_to_index(this.position);
        let cell_width = calculate_width() / 8;
        let for_white = color == "white";
        let left = cell_width * (for_white ? file - 1 : 8 - file);
        let top = cell_width * (for_white ? 8 - rank : rank - 1);
        left += cell_width * 0.5;
        top += cell_width * 0.5;
        this.elem.style.left = "" + left + "px";
        this.elem.style.top = "" + top + "px";
    }

    remove() {
        let id = this.id();
        document.getElementById(id).remove();
    }
}

class TextOverlayManager {
    constructor() {
        this.overlays = [];
        this.current_overlays = [];
    }

    /**
     * Add overlays to explain when certain arrow combinations appear.
     */
    setup_arrow_overlays(all_moves, clean_pgn_arrows, max, min, only_pgn = false) {
        let clean_legal_pgn_arrows = clean_pgn_arrows.filter(cal => {
            let ftc = cal_to_ftc(cal);
            return ground_is_legal_move(ftc.from, ftc.to);
        });

        let has_clean_legal_pgn_arrows = clean_legal_pgn_arrows.length > 0;
        let has_neglected_moves = some_moves_neglected(max, min);

        // Explain playable moves - when there's a PGN arrow and a playable move
        if (!this.seen_overlay(TextOverlayId.FIRST_PLAYABLE_MOVE) && has_clean_legal_pgn_arrows && !only_pgn) {
            this.set_current_overlay(TextOverlayId.FIRST_PLAYABLE_MOVE);
            let square = san_to_uci(chess, all_moves[0].move).to;
            this.add_info_overlay(i18n.overlay_playable_move, square);
        }
        // Explain PGN arrows - when there's a PGN arrow and a playable move
        else if (!this.seen_overlay(TextOverlayId.FIRST_PGN_ARROW) && has_clean_legal_pgn_arrows) {
            this.set_current_overlay(TextOverlayId.FIRST_PGN_ARROW);

            if (only_pgn) {
                // In PGN only mode, explain only PGN arrows
                let square = cal_to_ftc(clean_legal_pgn_arrows[0]).to;
                this.add_info_overlay(i18n.overlay_pgn_arrow_only, square);

            } else {
                // In 'PGN and auto' mode, we also explain all playable moves
                let playable_dest_squares = all_moves.map(m => san_to_uci(chess, m.move).to);
                for (let square of playable_dest_squares) {
                    this.add_info_overlay(i18n.overlay_playable_short, square);
                }
                // ..and a PGN arrow explanation
                let square = cal_to_ftc(clean_legal_pgn_arrows[0]).to;
                this.add_info_overlay(i18n.overlay_pgn_arrow, square);
            }
        }
        // Explain neglected moves
        else if (!this.seen_overlay(TextOverlayId.FIRST_NEGLECTED_MOVE, false) && has_neglected_moves && !only_pgn) {
            this.set_current_overlay(TextOverlayId.FIRST_NEGLECTED_MOVE);
            let freq_played = all_moves.filter(m => !current_move_neglected(m, max));
            let square = san_to_uci(chess, freq_played[0].move).to;
            this.add_info_overlay(i18n.overlay_frequently_played, square);
        }
    }

    /**
     * Sets/adds a current overlay
     */
    set_current_overlay(overlay_id) {
        if (!array_contains(this.current_overlays, overlay_id)) {
            this.current_overlays.push(overlay_id);
        }
    }

    /**
     * Return true if an overlay has been seen before.
     */
    seen_overlay(overlay_id) {
        let lsKey = study_id + "_overlay_" + overlay_id;
        return localStorage.getItem(lsKey) === "true";
    }

    /**
     * Return true if a specific overlay id is currently showing.
     */
    has_current_overlay(overlay_id) {
        return array_contains(this.current_overlays, overlay_id);
    }

    /**
     * Marks all current overlays as seen. This stores the fact in local storage and
     * clears the array of current overlays in preparation for the next move.
     */
    mark_current_overlays_seen() {
        for (let overlay_id of this.current_overlays) {
            let lsKey = study_id + "_overlay_" + overlay_id;
            localStorage.setItem(lsKey, true);
        }
        this.current_overlays = [];
    }

    add_info_overlay(text, square) {
        this.add_overlay(new TextOverlay(text, square, TextOverlayType.INFO, TextOverlayDuration.OneMove));
    }

    add_overlay(overlay) {
        this.overlays.push(overlay);
    }

    clear_overlays() {
        for (let overlay of this.overlays) {
            if (overlay.duration === TextOverlayDuration.OneMove) {
                overlay.remove();
            }
        }
        this.overlays = this.overlays.filter((x) => x.duration != TextOverlayDuration.OneMove);
    }

    on_resize() {
        for (let overlay of this.overlays) {
            overlay.resize();
        }
    }
}

export { TextOverlayDuration, TextOverlayType, TextOverlayId, TextOverlay, TextOverlayManager };
