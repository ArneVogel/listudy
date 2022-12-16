require("regenerator-runtime/runtime"); // required for sleep (https://github.com/babel/babel/issues/9849#issuecomment-487040428)

const Chessground = require('chessground').Chessground;
const Chess = require('chess.js')
import { turn_color, non_turn_color, setup_chess, uci_to_san, san_to_uci } from './modules/chess_utils.js';
import { string_hash } from './modules/hash.js';
import { clear_local_storage, get_option_from_localstorage } from './modules/localstorage.js';
import { tree_value_add, tree_progress, tree_move_index, tree_children, tree_possible_moves, has_children, tree_value,
         need_hint, update_value, value_sort, tree_get_node, tree_children_filter_sort, tree_get_node_depth,
         tree_get_node_string, tree_size_weighted_random_move, tree_max_num_moves_deep } from './modules/tree_utils.js';
import { generate_move_trees, annotate_pgn } from './modules/tree_from_pgn.js';
import { sleep } from './modules/sleep.js';
import { getRandomIntFromRange } from './modules/random.js';
import { unescape_string } from './modules/security_related.js';
import { ground_init_state, onresize, resize_ground, setup_ground, ground_set_moves,
         ground_undo_last_move, setup_move_handler, ground_move,
         TextOverlayDuration, TextOverlayType, TextOverlay, TextOverlayManager } from './modules/ground.js';
import { set_text, clear_all_text, success_div, info_div, error_div, suggestion_div } from './modules/info_boxes.js';

const mode_free = "free_mode";

const comments_div = "comments";

let combo_count = 0;

let seen_suggestions = [];
let first_pgn_arrow_seen = false;
let first_neglected_move_seen = false;

// Option to control how quickly the ai plays each move
let move_delay_time_key = "move_delay_time";
let move_delay_time = get_option_from_localstorage(move_delay_time_key, i18n.instant, [i18n.instant, i18n.fast, i18n.medium, i18n.slow]);

// Option to control how and when arrows are displayed
let show_arrows_key = "show_arrows";
let show_arrows = get_option_from_localstorage(show_arrows_key, i18n.arrows_new2x, [i18n.arrows_new2x, i18n.arrows_new5x, i18n.arrows_always, i18n.arrows_hidden]);

// Option to control how and when arrows are displayed
let arrow_type_key = "arrow_type";
let arrow_type = get_option_from_localstorage(arrow_type_key, i18n.arrow_type_both, [i18n.arrow_type_auto, i18n.arrow_type_pgn, i18n.arrow_type_both]);

// When enabled the board waits a few seconds at the end of the line before resetting.
let board_review_key = "board_review";
let board_review = get_option_from_localstorage(board_review_key, i18n.review_fast, [i18n.review_fast, i18n.review_slow]);

// When enabled, will skip to the first branch point in the PGN tree. If the move list is flat then this has no effect.
let key_moves_mode_key = "key_moves_mode";
let key_moves_mode = get_option_from_localstorage(key_moves_mode_key, i18n.key_move_enabled, [i18n.key_move_enabled, i18n.key_move_disabled]);

//  When enabled the comments from the opposite side's responses are also shown.
let show_comments_key = "show_comments";
let show_comments = get_option_from_localstorage(show_comments_key, i18n.comments_when_arrows, [i18n.comments_when_arrows, i18n.comments_always_on, i18n.comments_hidden]);

// Option to control the maximum number of moves being played
const DEPTH_MAX = -1;  // This constant is used to avoid having to calculate the tree depth when max_depth is at the max depth.
let max_depth_key_base = "max_depth_" + study_id + "_";
let max_depth = DEPTH_MAX;

function combo_text() {
    return "" + combo_count + "x ";
}

function right_move_text() {
    return combo_text() + i18n.success_right_move;
}

function achievement_end_of_line() {
    let t = localStorage.getItem("achievements_lines_learned") || 0;
    localStorage.setItem("achievements_lines_learned", Number(t) + 1);
    if (typeof achievement_student_test != "undefined") {
        document.dispatchEvent(achievement_student_test);
    }
    if (typeof achievement_student2_test != "undefined") {
        document.dispatchEvent(achievement_student2_test);
    }

}

// "cxb8=Q" => "cxb8="
// "abc" => ""
function san_promotion_prefix(san) {
    return san.substring(0, san.indexOf("=") + 1); 
}

// checks if the san would be a possible promotion
// expected result for 
//  moves: Array [ "cxb8=N" ]
//  san:   cxb8=Q
// would be "cxb8=Q.
// Returns "" if the san is not a possible promotion
// Used in handle_move to allow for underpromotions
function possible_promotion(moves, san) {
    let target_prefix = san_promotion_prefix(san);

    // this move did not promote
    if (target_prefix == "") {
        return ""; 
    }
    for (let m of moves) {
        let prefix = san_promotion_prefix(m);
        if (prefix == "") {
            continue;
        }
        if (prefix == target_prefix) {
            return m;
        }
    }
    return ""; 
}

async function handle_move(orig, dest) {
    overlay_manager.on_move();

    clear_all_text();

    total_moves += 1;

    let san = uci_to_san(chess, orig, dest);

    let possible_moves = tree_possible_moves(curr_move).map(m => m.move);

    let possible_promotion_san = possible_promotion(possible_moves, san);
    // the move automatically promoted to a queen, above we checked if it was
    // also possible to underpromote, if so we returned that san instead
    if (possible_promotion_san != "") {
        san = possible_promotion_san;
    }

    if(possible_moves.indexOf(san) != -1) {
        // console.log('curr_move', orig, dest, JSON.stringify(curr_move));
        // the move is one of the possible moves in the current position
        update_value(curr_move, 1, san);
        play_move(san);
        combo_count += 1;
        set_text(success_div, right_move_text());
        let reply = ai_move(curr_move);
        let end_of_line = reply == undefined;
        if (!end_of_line && max_depth !== DEPTH_MAX) {
            let curr_node = tree_get_node(curr_move);
            let curr_depth = tree_get_node_depth(curr_node);
            if (key_moves_mode == i18n.key_move_disabled || window.first_variation === null) {
                end_of_line = curr_depth >= max_depth;
            } else {
                end_of_line = curr_node.move_index >= window.first_variation && curr_depth >= max_depth;
            }
            // console.log('CURR_DEPTH', end_of_line, curr_node.move, curr_node.move_index, curr_depth);
        }
        await sleep(get_move_delay()); // instant play by the ai feels weird
        if (end_of_line) {
            achievement_end_of_line();
            set_text(success_div, right_move_text() + "\n" + i18n.success_end_of_line);
            if (board_review == i18n.review_slow) {
                await sleep(3000);
            }
            start_training();
        } else {
            play_move(reply);
        }
    } else {
        // wrong move at the current position
        update_value(curr_move, 0); //retrain all the possible replies
        combo_count = 0; //reset the combo
        // it is important that chess is set to the right position before
        // calling ground_undo_last_move(); since it used chess.fen() to
        // reset the position to the previous position
        ground_undo_last_move();
        set_text(error_div, i18n.error_wrong_move);
    }
    store_trees();
    setup_move();
    update_progress();
}

function create_shape(move, brush) {
    let ft = san_to_uci(chess, move);
    return {orig: ft.from, dest: ft.to, brush: brush};
}

function create_svg_info_shape(square) {
    //let ft = san_to_uci(chess, m.move);
    let shape = {orig: square, brush: "normal"};
    //shape.customSvg = '<?xml version="1.0" encoding="iso-8859-1"?><!-- Generator: Adobe Illustrator 19.1.0, SVG Export Plug-In . SVG Version: 6.00 Build 0)  --><svg version="1.1" id="Capa_1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="15%" y="25%" width="70%" height="70%"	 viewBox="0 0 297.703 297.703" style="enable-background:new 0 0 297.703 297.703;" xml:space="preserve"><g>	<path style="fill:#FF684D;" d="M40.16,77.084c0-20.462,16.646-37.108,37.108-37.108c3.313,0,6-2.687,6-6c0-3.313-2.687-6-6-6		c-27.078,0-49.108,22.03-49.108,49.108c0,3.313,2.687,6,6,6C37.473,83.084,40.16,80.397,40.16,77.084z"/>	<path style="fill:#FF684D;" d="M77.268,12c3.313,0,6-2.686,6-6c0-3.313-2.687-6-6-6C34.764,0,0.184,34.58,0.184,77.084		c0,3.313,2.687,6,6,6s6-2.687,6-6C12.184,41.196,41.38,12,77.268,12z"/>	<path style="fill:#FF684D;" d="M220.435,27.976c-3.314,0-6,2.687-6,6c0,3.313,2.686,6,6,6c20.462,0,37.108,16.646,37.108,37.108		c0,3.313,2.686,6,6,6s6-2.687,6-6C269.543,50.006,247.513,27.976,220.435,27.976z"/>	<path style="fill:#FF684D;" d="M220.435,0c-3.314,0-6,2.687-6,6c0,3.314,2.686,6,6,6c35.888,0,65.084,29.196,65.084,65.084		c0,3.313,2.686,6,6,6c3.313,0,6-2.687,6-6C297.519,34.58,262.939,0,220.435,0z"/>	<path style="fill:#FFD4C4;" d="M240.518,154.959v-48.976c0-7.359-5.645-13.381-13.005-13.381c-0.521,0-0.855,0.03-1.387,0.092		c-6.812,0.793-11.608,6.838-11.608,13.694v42.39c0,3.413-2.777,6.132-6.19,6.132h-0.111c-3.693,0-6.698-2.945-6.698-6.64V79.895		c0-6.857-4.984-12.902-11.795-13.695c-0.532-0.062-1.182-0.092-1.702-0.092c-7.36-0.001-13.502,6.021-13.502,13.381v69.028		c0,3.558-2.895,6.442-6.452,6.442c-3.61,0-6.548-2.928-6.548-6.538V60.625c0-6.856-4.855-12.902-11.667-13.694		c-0.532-0.062-1.246-0.093-1.767-0.093c-7.36,0-13.567,6.022-13.567,13.382v88.209c0,3.606-2.934,6.53-6.54,6.53		c-3.563,0-6.46-2.888-6.46-6.449V79.895c0-6.857-4.727-12.902-11.538-13.695c-0.532-0.062-1.311-0.092-1.831-0.092		c-7.36-0.001-13.631,6.021-13.631,13.381v99.605c0,3.695-2.644,6.164-5.811,6.164c-1.458,0-2.756-0.522-3.993-1.69l-15.779-14.99		c-2.576-2.576-5.924-3.864-9.32-3.864c-3.396,0-6.768,1.288-9.344,3.864c-5.151,5.152-5.139,13.583,0.012,18.734l56.408,74.39		c0.006,0.008,0.013,0.018,0.013,0.027l1.413,18.883c0.221,2.931,2.665,5.3,5.602,5.3c0.003,0,0.005,0,0.008,0l98.451-0.182		c2.816-0.003,5.195-2.145,5.562-4.938l2.569-19.596c0.11-0.838,0.037-1.646,0.493-2.357		C235.82,235.448,240.518,196.787,240.518,154.959z"/>	<path d="M227.513,80.603c-0.985,0-1.801,0.058-2.784,0.172c-4.218,0.491-8.21,2.021-11.21,4.319v-5.199		c0-13.116-9.63-24.128-22.409-25.614c-0.983-0.115-1.979-0.173-2.966-0.173c-5.229-0.001-10.219,1.579-14.435,4.514		c-0.923-12.218-10.215-22.164-22.337-23.574c-0.983-0.114-1.971-0.137-2.957-0.137h-0.005h-0.004		c-6.765,0-13.136,2.607-17.938,7.409c-4.424,4.424-7.017,10.162-7.396,16.332c-3.311-2.319-7.203-3.869-11.442-4.362		c-0.983-0.115-1.982-0.177-2.968-0.177c-6.765-0.001-13.516,2.641-18.318,7.442c-4.801,4.802-7.827,11.169-7.827,17.934v86.04		l-5.524-5.577c-4.742-4.67-10.834-7.239-17.522-7.239c-6.754,0-12.998,2.621-17.757,7.379c-9.619,9.619-9.791,25.133-0.611,35.021		l53.878,71.029l1.16,15.265c0.687,9.139,8.409,16.297,17.573,16.297l98.471-0.078c8.805-0.011,16.306-6.598,17.452-15.323		l2.388-18.182c7.557-12.231,12.779-28.446,16.272-48.228c3.051-17.273,4.221-37.775,4.221-60.934v-48.976		C252.518,91.988,241.509,80.603,227.513,80.603z M217.74,280.739c-0.366,2.793-2.745,4.986-5.562,4.989l-98.451,0.182		c-0.003,0-0.005,0-0.008,0c-2.938,0-5.38-2.369-5.601-5.3l-1.411-18.831c-0.001-0.01-0.004-0.045-0.011-0.053l-56.401-74.402		c-5.152-5.152-5.152-13.59,0-18.741c2.576-2.576,5.972-3.868,9.367-3.868c3.396,0,6.792,1.287,9.368,3.863l15.874,14.988		c1.237,1.168,2.344,1.691,3.802,1.691c3.167,0,5.811-2.47,5.811-6.165V79.488c0-7.359,6.402-13.382,13.762-13.381		c0.521,0,0.977,0.03,1.51,0.092c6.811,0.793,11.728,6.838,11.728,13.695v68.615c0,3.562,2.897,6.449,6.46,6.449		c3.606,0,6.54-2.924,6.54-6.53V60.22c0-7.36,6.274-13.382,13.633-13.382c0.52,0,1.042,0.03,1.574,0.093		c6.811,0.792,11.793,6.838,11.793,13.694v87.796c0,3.61,2.938,6.538,6.548,6.538c3.558,0,6.452-2.885,6.452-6.442V79.488		c0-7.359,6.145-13.382,13.505-13.381c0.52,0,1.105,0.03,1.637,0.092c6.811,0.793,11.857,6.838,11.857,13.695v68.376		c0,3.694,3.005,6.64,6.698,6.64h0.111c3.413,0,6.19-2.719,6.19-6.132v-42.39c0-6.856,4.985-12.901,11.795-13.694		c0.532-0.062,0.681-0.092,1.202-0.092c7.359,0,13.003,6.021,13.003,13.381v48.976c0,41.828-4.698,80.477-19.716,103.867		c-0.456,0.711-0.57,1.506-0.68,2.344L217.74,280.739z"/></g><g></g><g></g><g></g><g></g><g></g><g></g><g></g><g></g><g></g><g></g><g></g><g></g><g></g><g></g><g></g></svg>';
    //shape.customSvg = '<?xml version="1.0" encoding="iso-8859-1"?><!-- Generator: Adobe Illustrator 19.0.0, SVG Export Plug-In . SVG Version: 6.00 Build 0)  --><svg version="1.1" id="Layer_1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="5%" y="5%"	 width="70%" height="70%" viewBox="0 0 512.853 512.853" style="enable-background:new 0 0 512.853 512.853;" xml:space="preserve"><g transform="translate(1 1)">	<g>		<path style="fill:#FFE100;" d="M92.867,76.227c-5.12,0-8.533-3.413-8.533-8.533v-51.2c0-5.12,3.413-8.533,8.533-8.533			c5.12,0,8.533,3.413,8.533,8.533v51.2C101.4,72.813,97.987,76.227,92.867,76.227z"/>		<path style="fill:#FFE100;" d="M92.867,195.693c-5.12,0-8.533-3.413-8.533-8.533v-51.2c0-5.12,3.413-8.533,8.533-8.533			c5.12,0,8.533,3.413,8.533,8.533v51.2C101.4,192.28,97.987,195.693,92.867,195.693z"/>		<path style="fill:#FFE100;" d="M118.467,50.627c-2.56,0-4.267-0.853-5.973-2.56L92.867,28.44L73.24,48.067			c-3.413,3.413-8.533,3.413-11.947,0c-3.413-3.413-3.413-8.533,0-11.947l25.6-25.6c3.413-3.413,8.533-3.413,11.947,0l25.6,25.6			c3.413,3.413,3.413,8.533,0,11.947C122.733,49.773,121.027,50.627,118.467,50.627z"/>		<path style="fill:#FFE100;" d="M92.867,195.693c-2.56,0-4.267-0.853-5.973-2.56l-25.6-25.6c-3.413-3.413-3.413-8.533,0-11.947			s8.533-3.413,11.947,0l19.627,19.627l19.627-19.627c3.413-3.413,8.533-3.413,11.947,0s3.413,8.533,0,11.947l-25.6,25.6			C97.133,194.84,95.427,195.693,92.867,195.693z"/>		<path style="fill:#FFE100;" d="M58.733,110.36h-51.2c-5.12,0-8.533-3.413-8.533-8.533s3.413-8.533,8.533-8.533h51.2			c5.12,0,8.533,3.413,8.533,8.533S63.853,110.36,58.733,110.36z"/>		<path style="fill:#FFE100;" d="M178.2,110.36H127c-5.12,0-8.533-3.413-8.533-8.533s3.413-8.533,8.533-8.533h51.2			c5.12,0,8.533,3.413,8.533,8.533S183.32,110.36,178.2,110.36z"/>		<path style="fill:#FFE100;" d="M33.133,135.96c-2.56,0-4.267-0.853-5.973-2.56l-25.6-25.6c-3.413-3.413-3.413-8.533,0-11.947			l25.6-25.6c3.413-3.413,8.533-3.413,11.947,0c3.413,3.413,3.413,8.533,0,11.947L19.48,101.827l19.627,19.627			c3.413,3.413,3.413,8.533,0,11.947C37.4,135.107,35.693,135.96,33.133,135.96z"/>		<path style="fill:#FFE100;" d="M152.6,135.96c-2.56,0-4.267-0.853-5.973-2.56c-3.413-3.413-3.413-8.533,0-11.947l19.627-19.627			L146.627,82.2c-3.413-3.413-3.413-8.533,0-11.947c3.413-3.413,8.533-3.413,11.947,0l25.6,25.6c3.413,3.413,3.413,8.533,0,11.947			l-25.6,25.6C156.867,135.107,155.16,135.96,152.6,135.96z"/>		<path style="fill:#FFE100;" d="M237.933,281.027L229.4,263.96"/>		<path style="fill:#FFE100;" d="M476.867,221.293c0-18.773-15.36-34.133-34.133-34.133c-18.773,0-8.533,15.36-8.533,34.133v-42.667			c0-18.773-15.36-34.133-34.133-34.133s-34.133,15.36-34.133,34.133v-34.133c0-18.773-15.36-34.133-34.133-34.133			s-34.133,15.36-34.133,34.133v34.133V42.093c0-18.773,1.707-34.133-17.067-34.133S255,23.32,255,42.093V263.96l-15.36-23.04			c-2.56-5.12-5.973-9.387-10.24-12.8c-7.68-7.68,0.853,23.04-8.533,18.773c-8.533-3.413-34.133-41.813-42.667-42.667			c-8.533-0.853-17.067,0.853-23.893,3.413c-3.413,1.707-6.827,3.413-10.24,5.12c-10.24,6.827-8.533,14.507-8.533,17.067			s48.64,52.053,76.8,102.4c0,0,24.747,40.96,51.2,68.267v25.6c0,42.667,8.533,76.8,51.2,76.8h85.333			c33.28,0,41.813-28.16,49.493-60.587c1.707-7.68,5.12-18.773,10.24-24.747c7.68-8.533,17.067-29.867,17.067-59.733V221.293z"/>	</g>	<g>		<path style="fill:#FFFFFF;" d="M263.533,426.093v-25.6c-26.453-27.307-51.2-68.267-51.2-68.267			c-28.16-50.347-76.8-99.84-76.8-102.4s-1.707-10.24,8.533-17.067c3.413-1.707,5.973-4.267,10.24-5.12			c2.56-0.853,5.12-1.707,7.68-1.707c-11.947-2.56-23.04-1.707-33.28,1.707c-3.413,1.707-6.827,3.413-10.24,5.12			c-10.24,6.827-8.533,14.507-8.533,17.067s48.64,52.053,76.8,102.4c0,0,24.747,40.96,51.2,68.267v25.6			c0,42.667,8.533,76.8,51.2,76.8h25.6C272.067,502.893,263.533,468.76,263.533,426.093"/>		<path style="fill:#FFFFFF;" d="M239.64,240.92L255,263.96V42.093c0-12.8,3.413-24.747,11.947-29.867			c-2.56-2.56-5.973-4.267-11.947-4.267c-18.773,0-25.6,15.36-25.6,34.133V228.12C232.813,232.387,236.227,236.653,239.64,240.92"/>	</g>	<path style="fill:#FFA800;" d="M468.333,187.16c-4.267,0-8.533,0.853-12.8,2.56c12.8,5.12,21.333,17.067,21.333,31.573v136.533		c0,29.867-9.387,51.2-17.067,59.733c-5.12,5.973-8.533,17.067-10.24,24.747c-7.68,32.427-41.813,60.587-75.093,60.587h25.6		c33.28,0,67.413-28.16,75.093-60.587c1.707-7.68,5.12-18.773,10.24-24.747c7.68-8.533,17.067-29.867,17.067-59.733V221.293		C502.467,202.52,487.107,187.16,468.333,187.16"/>	<path id="SVGCleanerId_0" d="M237.933,289.56c-3.413,0-5.973-1.707-7.68-5.12l-8.533-17.067c-1.707-4.267,0-9.387,3.413-11.093		c4.267-1.707,9.387,0,11.093,3.413l8.533,17.067c1.707,4.267,0,9.387-3.413,11.093C240.493,289.56,239.64,289.56,237.933,289.56z"		/>	<path id="SVGCleanerId_1" d="M451.267,434.627c-3.413,0-6.827-2.56-8.533-5.973c-0.853-4.267,1.707-9.387,5.973-10.24l5.12-0.853		c18.773-5.12,29.013-7.68,32.427-18.773c1.707-4.267,5.973-6.827,11.093-5.12c4.267,1.707,6.827,5.973,5.12,11.093		c-6.827,20.48-25.6,24.747-44.373,29.867h-4.267C452.973,434.627,452.12,434.627,451.267,434.627z"/>	<path id="SVGCleanerId_2" d="M272.067,434.627c-1.707,0-3.413-0.853-5.12-1.707c-5.12-4.267-9.387-6.827-14.507-11.093		c-6.827-4.267-12.8-9.387-19.627-15.36c-3.413-3.413-3.413-8.533-0.853-11.947c3.413-3.413,8.533-3.413,11.947-0.853		c5.973,5.12,11.947,9.387,17.92,13.653c5.12,3.413,10.24,6.827,15.36,11.947c3.413,3.413,4.267,8.533,0.853,11.947		C277.187,433.773,274.627,434.627,272.067,434.627z"/>	<path d="M400.067,511.427h-85.333c-46.933,0-85.333-38.4-85.333-85.333v-22.187c-25.6-28.16-48.64-65.707-50.347-67.413		c-19.627-35.84-51.2-71.68-65.707-88.747c-11.947-13.653-12.8-14.507-11.947-19.627c0-3.413-0.853-14.507,11.947-23.04		c4.267-2.56,7.68-5.12,11.947-5.973c33.28-11.947,76.8,4.267,95.573,36.693v-82.773c0-5.12,3.413-8.533,8.533-8.533		c5.12,0,8.533,3.413,8.533,8.533V263.96c0,3.413-2.56,6.827-5.973,8.533c-3.413,0.853-7.68,0-9.387-3.413l-15.36-23.04		c-16.213-28.16-52.907-38.4-75.093-30.72c-2.56,0.853-5.12,2.56-8.533,4.267c-5.12,3.413-5.12,5.12-5.12,7.68		c1.707,1.707,5.12,5.973,7.68,9.387c15.36,17.92,47.787,54.613,68.267,91.307c0,0,24.747,40.107,50.347,66.56		c1.707,1.707,2.56,3.413,2.56,5.973v25.6c0,37.547,30.72,68.267,68.267,68.267h85.333c29.013,0,60.587-24.747,66.56-53.76		c2.56-12.8,6.827-23.04,11.947-29.013c5.12-5.973,15.36-24.747,15.36-53.76V221.293c0-14.507-11.093-25.6-25.6-25.6		s-25.6,11.093-25.6,25.6c0,5.12-3.413,8.533-8.533,8.533s-8.533-3.413-8.533-8.533v-42.667c0-14.507-11.093-25.6-25.6-25.6		s-25.6,11.093-25.6,25.6c0,5.12-3.413,8.533-8.533,8.533c-5.12,0-8.533-3.413-8.533-8.533v-34.133c0-14.507-11.093-25.6-25.6-25.6		c-14.507,0-25.6,11.093-25.6,25.6v34.133c0,5.12-3.413,8.533-8.533,8.533c-5.12,0-8.533-3.413-8.533-8.533V42.093		c0-14.507-11.093-25.6-25.6-25.6c-14.507,0-25.6,11.093-25.6,25.6V84.76c0,5.12-3.413,8.533-8.533,8.533		c-5.12,0-8.533-3.413-8.533-8.533V42.093c0-23.893,18.773-42.667,42.667-42.667c23.893,0,42.667,18.773,42.667,42.667v68.267		c6.827-5.12,16.213-8.533,25.6-8.533c23.893,0,42.667,18.773,42.667,42.667l0,0c6.827-5.12,16.213-8.533,25.6-8.533		c23.893,0,42.667,18.773,42.667,42.667v8.533c6.827-5.12,16.213-8.533,25.6-8.533c23.893,0,42.667,18.773,42.667,42.667v136.533		c0,31.573-10.24,55.467-18.773,65.707c-3.413,3.413-5.973,11.093-8.533,21.333C475.16,480.707,436.76,511.427,400.067,511.427z"/>	<path d="M237.933,118.893c0-5.12-3.413-8.533-8.533-8.533c-5.12,0-8.533,3.413-8.533,8.533s3.413,8.533,8.533,8.533		C234.52,127.427,237.933,124.013,237.933,118.893"/>	<path d="M92.867,67.693c-5.12,0-8.533-3.413-8.533-8.533V7.96c0-5.12,3.413-8.533,8.533-8.533c5.12,0,8.533,3.413,8.533,8.533v51.2		C101.4,64.28,97.987,67.693,92.867,67.693z"/>	<path d="M92.867,187.16c-5.12,0-8.533-3.413-8.533-8.533v-51.2c0-5.12,3.413-8.533,8.533-8.533c5.12,0,8.533,3.413,8.533,8.533		v51.2C101.4,183.747,97.987,187.16,92.867,187.16z"/>	<path d="M118.467,42.093c-2.56,0-4.267-0.853-5.973-2.56L92.867,19.907L73.24,39.533c-3.413,3.413-8.533,3.413-11.947,0		c-3.413-3.413-3.413-8.533,0-11.947l25.6-25.6c3.413-3.413,8.533-3.413,11.947,0l25.6,25.6c3.413,3.413,3.413,8.533,0,11.947		C122.733,41.24,121.027,42.093,118.467,42.093z"/>	<path d="M92.867,187.16c-2.56,0-4.267-0.853-5.973-2.56l-25.6-25.6c-3.413-3.413-3.413-8.533,0-11.947s8.533-3.413,11.947,0		l19.627,19.627l19.627-19.627c3.413-3.413,8.533-3.413,11.947,0s3.413,8.533,0,11.947l-25.6,25.6		C97.133,186.307,95.427,187.16,92.867,187.16z"/>	<path d="M58.733,101.827h-51.2c-5.12,0-8.533-3.413-8.533-8.533c0-5.12,3.413-8.533,8.533-8.533h51.2		c5.12,0,8.533,3.413,8.533,8.533C67.267,98.413,63.853,101.827,58.733,101.827z"/>	<path d="M178.2,101.827H127c-5.12,0-8.533-3.413-8.533-8.533c0-5.12,3.413-8.533,8.533-8.533h51.2c5.12,0,8.533,3.413,8.533,8.533		C186.733,98.413,183.32,101.827,178.2,101.827z"/>	<path d="M33.133,127.427c-2.56,0-4.267-0.853-5.973-2.56l-25.6-25.6c-3.413-3.413-3.413-8.533,0-11.947l25.6-25.6		c3.413-3.413,8.533-3.413,11.947,0s3.413,8.533,0,11.947L19.48,93.293l19.627,19.627c3.413,3.413,3.413,8.533,0,11.947		C37.4,126.573,35.693,127.427,33.133,127.427z"/>	<path d="M152.6,127.427c-2.56,0-4.267-0.853-5.973-2.56c-3.413-3.413-3.413-8.533,0-11.947l19.627-19.627l-19.627-19.627		c-3.413-3.413-3.413-8.533,0-11.947c3.413-3.413,8.533-3.413,11.947,0l25.6,25.6c3.413,3.413,3.413,8.533,0,11.947l-25.6,25.6		C156.867,126.573,155.16,127.427,152.6,127.427z"/>	<g>		<path id="SVGCleanerId_0_1_" d="M237.933,289.56c-3.413,0-5.973-1.707-7.68-5.12l-8.533-17.067c-1.707-4.267,0-9.387,3.413-11.093			c4.267-1.707,9.387,0,11.093,3.413l8.533,17.067c1.707,4.267,0,9.387-3.413,11.093C240.493,289.56,239.64,289.56,237.933,289.56z"			/>	</g>	<path d="M297.667,289.56c-5.12,0-8.533-3.413-8.533-8.533v-102.4c0-5.12,3.413-8.533,8.533-8.533s8.533,3.413,8.533,8.533v102.4		C306.2,286.147,302.787,289.56,297.667,289.56z"/>	<path d="M365.933,281.027c-5.12,0-8.533-3.413-8.533-8.533v-93.867c0-5.12,3.413-8.533,8.533-8.533s8.533,3.413,8.533,8.533v93.867		C374.467,277.613,371.053,281.027,365.933,281.027z"/>	<path d="M434.2,289.56c-5.12,0-8.533-3.413-8.533-8.533v-59.733c0-5.12,3.413-8.533,8.533-8.533c5.12,0,8.533,3.413,8.533,8.533		v59.733C442.733,286.147,439.32,289.56,434.2,289.56z"/>	<g>		<path id="SVGCleanerId_1_1_" d="M451.267,434.627c-3.413,0-6.827-2.56-8.533-5.973c-0.853-4.267,1.707-9.387,5.973-10.24			l5.12-0.853c18.773-5.12,29.013-7.68,32.427-18.773c1.707-4.267,5.973-6.827,11.093-5.12c4.267,1.707,6.827,5.973,5.12,11.093			c-6.827,20.48-25.6,24.747-44.373,29.867h-4.267C452.973,434.627,452.12,434.627,451.267,434.627z"/>	</g>	<g>		<path id="SVGCleanerId_2_1_" d="M272.067,434.627c-1.707,0-3.413-0.853-5.12-1.707c-5.12-4.267-9.387-6.827-14.507-11.093			c-6.827-4.267-12.8-9.387-19.627-15.36c-3.413-3.413-3.413-8.533-0.853-11.947c3.413-3.413,8.533-3.413,11.947-0.853			c5.973,5.12,11.947,9.387,17.92,13.653c5.12,3.413,10.24,6.827,15.36,11.947c3.413,3.413,4.267,8.533,0.853,11.947			C277.187,433.773,274.627,434.627,272.067,434.627z"/>	</g></g><g></g><g></g><g></g><g></g><g></g><g></g><g></g><g></g><g></g><g></g><g></g><g></g><g></g><g></g><g></g></svg>';
    //shape.customSvg = '<svg width="70%" x="35%" y="30%" height="70%" viewBox="0 0 128 128" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" aria-hidden="true" role="img" class="iconify iconify--noto" preserveAspectRatio="xMidYMid meet"><linearGradient id="IconifyId17ecdb2904d178eab5773" x1="1469.9" x2="1586.5" y1="-1397.1" y2="-1397.1" gradientTransform="matrix(-.0021 1 1 .0021 1464.4 -1461.3)" gradientUnits="userSpaceOnUse"><stop stop-color="#FFCA28" offset=".353"></stop><stop stop-color="#FFB300" offset=".872"></stop></linearGradient><path d="M54.45 122.01a2.489 2.489 0 0 1-2.4-1.93l-.3-1.29c-1.48-6.37-5.2-12.04-10.75-16.42c-1.19-.94-2.21-2.06-3.04-3.33c-4.44-6.85-6.89-12.87-9.25-18.69c-2.23-5.51-4.34-10.71-7.93-16.08c-.8-1.2-1.38-4.5-.5-7.14c.56-1.7 1.62-2.84 3.14-3.37c1.22-.43 2.33-.64 3.39-.64c3.77 0 7.07 2.81 10.71 9.12c3.89 6.73 4.13 8.5 4.14 8.57c.03.81.69 1.43 1.5 1.43h.02c.82-.01 1.47-.7 1.48-1.52l.12-57.07c0-2.08 1.26-7.99 6.85-7.99c6.58 0 8.79 5.73 8.79 8.34l-.04 19.58c0 .47.22.92.6 1.21c.26.2.58.3.9.3c.14 0 .29-.02.43-.06c1.42-.43 2.79-.64 4.06-.64c3.8 0 6.26 1.95 7.65 3.59A5.785 5.785 0 0 0 78.44 40c.62 0 1.23-.1 1.81-.29c.73-.24 1.51-.36 2.32-.36c1.29 0 2.68.31 4.1.92c1.89.81 3.29 2.24 4.14 3.31c.9 1.13 2.75 3.03 5 3.03c.34 0 .67-.04.99-.13c.48-.13 1.05-.2 1.65-.2c2.73 0 6.31 1.36 8.13 5.18c1.65 3.44 1.61 22.48 1.59 28.73c-.04 16.46-11.38 39.89-11.49 40.13c-.04.08-.07.16-.1.25a2.505 2.505 0 0 1-2.4 1.82l-39.73-.38z" fill="url(#IconifyId17ecdb2904d178eab5773)"></path><path d="M51.62 7.14c5.99 0 7.29 5.48 7.29 6.83l-.04 19.59c0 .95.45 1.84 1.21 2.41a2.979 2.979 0 0 0 2.65.46c1.28-.39 2.5-.58 3.63-.58c2.59 0 4.78 1.03 6.51 3.06a7.29 7.29 0 0 0 5.56 2.55c.78 0 1.54-.12 2.28-.36c.58-.19 1.2-.29 1.86-.29c1.09 0 2.27.27 3.51.8c1.6.68 2.81 1.93 3.55 2.86c1.07 1.34 3.29 3.59 6.17 3.59c.47 0 .94-.06 1.39-.19c.34-.09.79-.15 1.26-.15c2.28 0 5.25 1.14 6.78 4.33c.68 1.43 1.49 7.46 1.45 28.08c-.03 16.1-11.23 39.24-11.34 39.47c-.08.16-.14.33-.19.5c-.12.43-.52.73-.98.73l-39.69-.35a.995.995 0 0 1-.96-.77l-.3-1.29c-1.56-6.7-5.46-12.67-11.29-17.25c-1.06-.84-1.97-1.84-2.71-2.97c-4.37-6.73-6.78-12.68-9.12-18.44c-2.26-5.58-4.4-10.85-8.07-16.35c-.45-.68-1.11-3.48-.32-5.84c.56-1.67 1.53-2.19 2.22-2.43c1.06-.38 2-.56 2.89-.56c2.13 0 5.13.95 9.41 8.37c3.27 5.67 3.86 7.65 3.94 8c.12 1.5 1.34 2.69 2.87 2.76h.12c1.56 0 2.87-1.2 2.99-2.76c.01-.08.01-.17.01-.26l.12-57.07c-.01-.05.22-6.48 5.34-6.48m0-3c-6.34 0-8.35 6.34-8.35 9.49l-.12 57.07v.03v-.03c-.01-.24-.21-2.09-4.33-9.23c-3.86-6.69-7.57-9.87-12.01-9.87c-1.23 0-2.53.25-3.89.73c-5.76 2.05-5.06 10.25-3.39 12.76c7.26 10.88 8.43 21.3 17.17 34.76a15.36 15.36 0 0 0 3.37 3.69c5.03 3.96 8.77 9.34 10.22 15.58l.3 1.29a4.005 4.005 0 0 0 3.85 3.09l39.69.35h.04c1.79 0 3.36-1.19 3.85-2.91c0 0 11.61-23.79 11.64-40.78c.02-11.55-.14-26.04-1.74-29.38c-2.16-4.52-6.37-6.03-9.49-6.03c-.76 0-1.46.09-2.05.25c-.2.05-.4.08-.6.08c-1.44 0-2.9-1.3-3.82-2.46c-1.05-1.32-2.62-2.85-4.72-3.75c-1.78-.76-3.35-1.04-4.69-1.04c-1.08 0-2.01.18-2.79.43c-.44.14-.89.21-1.35.21c-1.24 0-2.45-.53-3.28-1.5c-1.64-1.93-4.46-4.11-8.79-4.11c-1.35 0-2.84.21-4.49.71l.04-19.59c.02-3.16-2.61-9.84-10.27-9.84z" fill="#EDA600"></path><path d="M59.36 53.71l-.46-21.17l2.45 1.7c.59 0 1.04.77.97 1.65l-.77 17.84c-.14 1.78-2.1 1.76-2.19-.02z" fill="#EDA600"></path><path d="M43.2 78.73l-2.81-6.97l-.94-2.47l3.32.87l3.23.94l-.09 7.48c.01 1.38-2.15 1.24-2.71.15z" fill="#EDA600"></path><path d="M76.47 54.11l-.77-13.07c-.05-.59 2.52-.25 2.52-.25c.59 0 1.04.53.97 1.13l-.77 12.23c-.13 1.21-1.85 1.18-1.95-.04z" fill="#EDA600"></path><path d="M93.1 53.88l-.77-7.04c-.05-.32 2.52-.13 2.52-.13c.59 0 1.04.28.97.61l-.77 6.58c-.14.65-1.86.63-1.95-.02z" fill="#EDA600"></path></svg>';
    //shape.customSvg = '<?xml version="1.0" encoding="iso-8859-1"?><!-- Generator: Adobe Illustrator 19.0.0, SVG Export Plug-In . SVG Version: 6.00 Build 0)  --><svg version="1.1" id="Layer_1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="-5%" y="35%"	width="65%" height="65%"  viewBox="0 0 502.664 502.664" style="enable-background:new 0 0 502.664 502.664;" xml:space="preserve"><g transform="translate(1 1)">	<path style="fill:#FFA800;" d="M216.593,492.836l24.717-24.717c47.669-7.062,44.138-7.062,105.931-68.855l75.034-75.034		c12.359-12.359,15.007-34.428,3.531-46.786c-12.359-12.359-34.428-8.828-46.786,3.531l-24.717,24.717l56.497-56.497		c12.359-12.359,15.007-34.428,3.531-46.786c-12.359-12.359-34.428-8.828-46.786,3.531l-44.138,43.255l68.855-68.855		c12.359-12.359,15.007-34.428,3.531-46.786c-12.359-12.359-34.428-8.828-46.786,3.531l-62.676,62.676L423.158,62.05		c11.476-11.476,15.007-34.428,2.648-46.786c-12.359-12.359-34.428-8.828-46.786,3.531L204.234,193.581		c17.655-17.655,37.076-67.09,37.076-99.752c0-27.366-47.669-57.379-56.497-6.179c-6.179,35.31-39.724,89.159-62.676,112.11		c-55.614,55.614-30.897,118.29-30.897,118.29l-24.717,24.717"/>	<path style="fill:#FFE100;" d="M202.468,477.83l26.483-26.483c47.669-7.062,44.138-7.062,105.931-68.855l75.034-75.034		c12.359-12.359,15.007-34.428,3.531-46.786c-11.476-12.359-34.428-8.828-46.786,3.531l-26.483,24.717l74.152-47.669		c12.359-12.359,15.007-34.428,3.531-46.786c-12.359-12.359-34.428-8.828-46.786,3.531l-44.138,43.255l68.855-68.855		c12.359-12.359,15.007-34.428,3.531-46.786c-11.476-12.359-34.428-8.828-46.786,3.531l-62.676,62.676L426.689,54.988		c12.359-12.359,6.179-25.6-5.297-37.959s-28.248-11.476-40.607,0L208.648,185.636c17.655-17.655,37.076-67.09,37.076-99.752		c0-18.538-49.434-48.552-56.497-6.179c-6.179,35.31-39.724,89.159-62.676,112.11C71.82,247.43,95.655,318.933,95.655,318.933		l-24.717,27.366"/>	<path d="M195.406,386.023c-2.648,0-4.414-0.883-6.179-2.648l-17.655-17.655c-3.531-3.531-3.531-8.828,0-12.359		c3.531-3.531,8.828-3.531,12.359,0l17.655,17.655c3.531,3.531,3.531,8.828,0,12.359C199.82,385.14,198.055,386.023,195.406,386.023		z"/>	<path d="M177.751,421.333c-2.648,0-4.414-0.883-6.179-2.648l-35.31-35.31c-3.531-3.531-3.531-8.828,0-12.359s8.828-3.531,12.359,0		l35.31,35.31c3.531,3.531,3.531,8.828,0,12.359C182.165,420.45,180.399,421.333,177.751,421.333z"/>	<path d="M67.406,352.478c-2.648,0-4.414-0.883-6.179-2.648c-3.531-3.531-3.531-8.828,0-12.359l21.186-22.069		c-5.297-17.655-15.007-72.386,35.31-122.703c23.834-23.834,54.731-75.917,60.028-107.697c5.297-34.428,27.366-35.31,34.428-34.428		c20.303,1.766,39.724,22.069,39.724,42.372c0,15.89-3.531,33.545-9.71,51.2l65.324-65.324c3.531-3.531,8.828-3.531,12.359,0		c3.531,3.531,3.531,8.828,0,12.359L210.413,199.761l0,0c-3.531,3.531-8.828,3.531-12.359,0c-3.531-3.531-3.531-8.828,0-12.359l0,0		c15.007-15.007,34.428-62.676,34.428-93.572c0-10.593-12.359-23.834-22.952-24.717c-9.71-0.883-14.124,10.593-15.007,20.303		c-6.179,38.841-42.372,94.455-65.324,117.407c-50.317,49.434-30.014,105.931-29.131,108.579c1.766,2.648,0.883,7.062-1.766,8.828		l-24.717,24.717C71.82,351.595,69.172,352.478,67.406,352.478z"/>	<path d="M216.593,501.664c-2.648,0-4.414-0.883-6.179-2.648c-3.531-3.531-3.531-8.828,0-12.359l24.717-24.717		c1.766-1.766,3.531-1.766,5.297-2.648c40.607-6.179,40.607-6.179,88.276-52.966l87.393-87.393		c8.828-8.828,11.476-25.6,3.531-34.428c-5.297-5.297-12.359-5.297-16.772-5.297c-6.179,0.883-12.359,3.531-16.772,7.062l-25.6,25.6		c-3.531,3.531-8.828,3.531-12.359,0c-3.531-3.531-3.531-8.828,0-12.359l24.717-24.717c0.883-0.883,0.883-0.883,1.766-1.766		l30.014-30.014c8.828-8.828,11.476-25.6,3.531-34.428c-8.828-8.828-25.6-5.297-34.428,3.531l-44.138,43.255		c-3.531,3.531-8.828,3.531-12.359,0s-3.531-8.828,0-12.359l68.855-68.855c8.828-8.828,11.476-25.6,3.531-34.428		c-5.297-5.297-12.359-5.297-16.772-5.297c-6.179,0.883-13.241,3.531-17.655,7.945l-62.676,62.676		c-3.531,3.531-8.828,3.531-12.359,0c-3.531-3.531-3.531-8.828,0-12.359l62.676-62.676c0,0,0,0,0.883-0.883l74.152-74.152		c4.414-4.414,7.062-11.476,7.945-17.655c0-3.531,0-11.476-5.297-16.772c-8.828-8.828-25.6-5.297-34.428,3.531L363.13,47.043		c-3.531,3.531-8.828,3.531-12.359,0c-3.531-3.531-3.531-8.828,0-12.359l22.952-22.952c14.124-14.124,42.372-18.538,58.262-2.648		c7.062,7.062,11.476,18.538,9.71,30.014c0,11.476-5.297,22.069-12.359,29.131l-49.434,49.434c7.945,0.883,15.89,4.414,21.186,9.71		c15.89,15.89,11.476,44.138-2.648,59.145c7.945,0.883,15.89,4.414,21.186,9.71c15.89,15.89,11.476,45.021-3.531,59.145		l-5.297,5.297c7.945,0.883,15.89,4.414,21.186,9.71c15.89,15.89,11.476,44.138-3.531,59.145l-87.393,87.393		c-48.552,48.552-51.2,51.2-95.338,58.262l-22.952,22.952C221.006,500.781,219.241,501.664,216.593,501.664z"/>	<path d="M342.827,64.699c0-5.297-3.531-8.828-8.828-8.828c-5.297,0-8.828,3.531-8.828,8.828s3.531,8.828,8.828,8.828		C339.296,73.526,342.827,69.995,342.827,64.699"/></g><g></g><g></g><g></g><g></g><g></g><g></g><g></g><g></g><g></g><g></g><g></g><g></g><g></g><g></g><g></g></svg>';
    //shape.customSvg = '<svg width="60%" height="60%" x="42%" y="0" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M12 2C6.4898 2 2 6.4898 2 12C2 17.5102 6.4898 22 12 22C17.5102 22 22 17.5102 22 12C22 6.4898 17.5102 2 12 2ZM12.8163 15.5714C12.8163 15.9796 12.5102 16.3878 12 16.3878C11.4898 16.3878 11.1837 16.0816 11.1837 15.5714V11.4898C11.1837 11.0816 11.4898 10.6735 12 10.6735C12.5102 10.6735 12.8163 10.9796 12.8163 11.4898V15.5714ZM12 9.44898C11.4898 9.44898 10.9796 8.93878 10.9796 8.42857C10.9796 7.91837 11.4898 7.40816 12 7.40816C12.5102 7.40816 13.0204 7.91837 13.0204 8.42857C13.0204 8.93878 12.5102 9.44898 12 9.44898Z" fill="#030D45"/></svg>';
    shape.customSvg = '<svg width="60%" height="60%" x="42%" y="0" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg"><path fill-rule="evenodd" clip-rule="evenodd" d="M12 3.53846C7.32682 3.53846 3.53846 7.32682 3.53846 12C3.53846 16.6732 7.32682 20.4615 12 20.4615C16.6732 20.4615 20.4615 16.6732 20.4615 12C20.4615 7.32682 16.6732 3.53846 12 3.53846ZM2 12C2 6.47715 6.47715 2 12 2C17.5228 2 22 6.47715 22 12C22 17.5228 17.5228 22 12 22C6.47715 22 2 17.5228 2 12Z" fill="#030D45"/><path fill-rule="evenodd" clip-rule="evenodd" d="M12 16.359C12.4248 16.359 12.7692 16.0146 12.7692 15.5897V11.4872C12.7692 11.0623 12.4248 10.7179 12 10.7179C11.5752 10.7179 11.2308 11.0623 11.2308 11.4872V15.5897C11.2308 16.0146 11.5752 16.359 12 16.359Z" fill="#030D45"/><path d="M13.0256 8.41026C13.0256 7.84381 12.5664 7.38462 12 7.38462C11.4336 7.38462 10.9744 7.84381 10.9744 8.41026C10.9744 8.9767 11.4336 9.4359 12 9.4359C12.5664 9.4359 13.0256 8.9767 13.0256 8.41026Z" fill="#030D45"/></svg>';
    //shape.customSvg = '<svg width="55%" height="55%" x="48%" y="-3%" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><path d="M12,14a1,1,0,1,0,1,1A1,1,0,0,0,12,14ZM12,2A10,10,0,0,0,2,12a9.89,9.89,0,0,0,2.26,6.33l-2,2a1,1,0,0,0-.21,1.09A1,1,0,0,0,3,22h9A10,10,0,0,0,12,2Zm0,18H5.41l.93-.93a1,1,0,0,0,.3-.71,1,1,0,0,0-.3-.7A8,8,0,1,1,12,20ZM12,8a1,1,0,0,0-1,1v3a1,1,0,0,0,2,0V9A1,1,0,0,0,12,8Z"/></svg>';
    return shape;
}

function some_moves_neglected(max, min) {
    return min < (0.5 * max);
}

function current_move_neglected(move, max) {
    return move.value < (0.5 * max)
}
/**
 * Create a playable arrow.
 * 
 * @param {*} m  The move to create an arrow for.
 * @param {*} max  The number of times the most played candidate move has been played.
 * @param {*} min  The number of times the least played candidate move has been played.
 * @param {*} pgn_color  The color of the arrow to be created, or undefined for classic playable only arrows.
 */
function create_playable_arrow(m, max, min, pgn_color = undefined) {
    let move = m.move;
    let some_neglected = some_moves_neglected(max, min);
    let current_neglected = current_move_neglected(m, max);
    let brush = undefined;
    if(pgn_color) {  // pgn arrows
        let brush_prefix = some_neglected ? 
            (current_neglected ? "playable_pgn_normal_" : "playable_pgn_transparent_") : "playable_pgn_normal_";
        brush = brush_prefix + pgn_color;
    } else {  // normal auto arrows
        brush = some_neglected ? (current_neglected ? "normal" : "transparent") : "normal";
    }
    return create_shape(move, brush);
}

/**
 * Create an arrow that represents a pure PGN arrow, that is not playable, but only exists as an arrow
 * in the PGN file.
 * @param {*} cal  The cal value (ie "Gd2d4" for a Green d2 -> d4 arrow).
 * @param {*} brush_prefix  Prefix for the brush.
 */
function create_pgn_arrow(cal, brush_prefix = "") {
    let brush = brush_prefix + get_color_from_cal(cal);
    let from = cal.substr(1, 2);
    let to = cal.substr(3, 2);
    let modifiers = {};
    return {orig: from, dest: to, brush: brush, modifiers: modifiers};
}

/**
 * Creates a circle from the PGN.
 * @param {*} csl  The csl value from the PGN file (ie Bd2 for a Blue circle on d2).
 */
function create_pgn_circle(csl) {
    let brush = get_color_from_cal(csl);
    let from = csl.substr(1, 2);
    return {orig: from, brush: brush};
}

/**
 * Returns true if arrows should be shown.
 */
function give_hints(once) {
    if (once || show_arrows == i18n.arrows_always) {
        return true;
    }

    let all_moves = tree_possible_moves(curr_move);
    let min = Math.min(...all_moves.map(m => m.value));
    if (show_arrows == i18n.arrows_new2x && min < 2 ||
        show_arrows == i18n.arrows_new5x && min < 5) {
        return true;
    }
    return false;
}

/**
 * Returns the PGN shapes (circles and arrows) from a move in the PGN file.
 * @param {*} m  The move.
 * @param {*} keyword  'cal' for arrows, and 'csl' for circles.
 */
function get_pgn_shapes(m, keyword) {
    if (m.comments != undefined) {
        let commands = m.comments.filter(c => c.commands != undefined).flatMap(c => c.commands);
        return commands.filter(cmd => cmd.key == keyword).flatMap(cmd => cmd.values);
    } else {
        return [];
    }
}

function array_contains(arr, str) {
    return arr.indexOf(str) > -1;
}

function get_color_from_cal(cal) {
    let c = cal[0];
    switch (c) {
        case "G":
            return "green";
        case "R":
            return "red";
        case "Y":
            return "yellow";
        case "B":
        default:
            return "blue";
    }
}

function get_ucistr_from_cal(cal) {
    return cal.substr(1,4);
}

// Ex get "e4" from "Ye2e4"
function get_dest_square_from_cal(cal) {
    return cal.substr(3,2);
}

function get_ucistr_from_move(m) {
    let uci = san_to_uci(chess, m.move);
    return "" + uci.from + uci.to;
}

/**
 * Combines all playable moves and all PGN arrows from the PGN file and returns the intersection of
 * those two sets, ie all PGN arrows that are also playable moves. A special object contianing information
 * from both the move and the PGN arrow is returned.
 */
function get_doubled_playable_move_objects(all_moves, all_pgn_arrows) {
    // Setup some lookup tables
    let all_pgn_arrow_uci = [];
    let color_by_pgn_arrow_uci = {};
    for (let cal of all_pgn_arrows) {
        let ucistr = get_ucistr_from_cal(cal);
        let color = get_color_from_cal(cal);
        
        color_by_pgn_arrow_uci[ucistr] = color;
        all_pgn_arrow_uci.push(ucistr);
    }

    // Merge the playable moves and the pgn arrows
    let union = all_moves.map(move => {
        let uci = get_ucistr_from_move(move);
        let color = color_by_pgn_arrow_uci[uci];
        return {
            color: color,
            uci: uci,
            move: move
        };
    })
    // And filter so that only those moves that are both playable a pgn arrow are left
    return union.filter(x => array_contains(all_pgn_arrow_uci, x.uci))
}

function get_arrow_hints(all_moves, pgn_arrows, max, min) {
    let shapes = [];

    // Find out if it's the first time we see a PGN arrow and create svg info shapes for them
    if (!first_pgn_arrow_seen) {
        first_pgn_arrow_seen = pgn_arrows.length > 0;
        let dest_squares = pgn_arrows.map(cal => get_dest_square_from_cal(cal));
        //shapes.push(...dest_squares.map(square => create_svg_info_shape(square)));
        for (let square of dest_squares) {
            if (key_moves_mode == i18n.key_move_enabled) {
                shapes.push(create_svg_info_shape(square));
            } else {
                overlay_manager.add_overlay(new TextOverlay("This is a PGN arrow!", square, TextOverlayType.INFO, TextOverlayDuration.OneMove));
            }
        }
    }
    // Find out if it's the first time we see a neglected move arrow and create svg info shapes for them
    else if (!first_neglected_move_seen && some_moves_neglected(max, min)) {
        first_neglected_move_seen = true;
        let freq_played = all_moves.filter(m => !current_move_neglected(m, max));
        let dest_squares = freq_played.map(m => san_to_uci(chess, m.move).to);
        //shapes.push(...dest_squares.map(square => create_svg_info_shape(square)));
        for (let square of dest_squares) {
            if (key_moves_mode == i18n.key_move_enabled) {
                shapes.push(create_svg_info_shape(square));
            } else {
                overlay_manager.add_overlay(new TextOverlay("This move has been played\nbefore. Maybe play another!", square, TextOverlayType.INFO, TextOverlayDuration.OneMove));
            }
        }
    }
    return shapes;
}


/**
 * Update the hints/arrows on the board, depending on the current setting of the variable show_arrows.
 * @param {*} once  Pass true to override any value of variable show_arrows and display hints temporarily.
 */
function display_arrows(once) {
    let all_moves = tree_possible_moves(curr_move);
    let current_move = tree_get_node(curr_move);
    let min = Math.min(...all_moves.map(m => m.value));
    let max = Math.max(...all_moves.map(m => m.value));
    let shapes = [];

    if (!give_hints(once)) {
        ground.setShapes(shapes);
        return;
    }

    if (arrow_type == i18n.arrow_type_auto) {
        shapes.push(...all_moves.map(m => create_playable_arrow(m, max, min)));

    } else if (arrow_type == i18n.arrow_type_pgn) {
        let all_pgn_circles = get_pgn_shapes(current_move, "csl");
        let all_pgn_arrows = get_pgn_shapes(current_move, "cal");

        shapes.push(...all_pgn_circles.map(a => create_pgn_circle(a)));
        shapes.push(...all_pgn_arrows.map(a => create_pgn_arrow(a)));

        let arrow_hints = get_arrow_hints(all_moves, clean_pgn_arrows, max, min)
        shapes.push(...arrow_hints);

    } else if (arrow_type = i18n.arrow_type_both) {
        // Circles from PGN
        let all_pgn_circles = get_pgn_shapes(current_move, "csl");
        shapes.push(...all_pgn_circles.map(a => create_pgn_circle(a)));

        // Prepare
        let all_pgn_arrows = get_pgn_shapes(current_move, "cal");
        let all_pgn_arrows_uci = all_pgn_arrows.map(cal => get_ucistr_from_cal(cal));
        let all_playable_moves_uci = all_moves.map(m => get_ucistr_from_move(m));
        // Get all three categories of arrows
        let clean_playable_moves = all_moves.filter(m => !array_contains(all_pgn_arrows_uci, get_ucistr_from_move(m)));
        let doubled_playable_move_objects = get_doubled_playable_move_objects(all_moves, all_pgn_arrows);
        let clean_pgn_arrows = all_pgn_arrows.filter(cal => !array_contains(all_playable_moves_uci, get_ucistr_from_cal(cal)));

        // Playable moves that don't have a corresponding PGN arrow
        shapes.push(...clean_playable_moves.map(m => create_playable_arrow(m, max, min, "blue")));

        // Playable moves that DO have a corresponding PGN arrow
        shapes.push(...doubled_playable_move_objects.map(x => create_playable_arrow(x.move, max, min, x.color)));

        // PGN arrows that only exist as arrows and are not playable
        shapes.push(...clean_pgn_arrows.map(a => create_pgn_arrow(a, "decorate_pgn_")));

        let arrow_hints = get_arrow_hints(all_moves, clean_pgn_arrows, max, min)
        shapes.push(...arrow_hints);
    }
    ground.setShapes(shapes);
}

function capitalize_first_letter(word) {
    return word.charAt(0).toUpperCase() + word.slice(1);
}

function create_comment(container_div, response_num, move) {
    var comment_div = document.createElement('div');
    comment_div.id = 'comment' + response_num;

    var bold_text_elem = document.createElement('div');
    bold_text_elem.id = comment_div.id + "_bold";
    bold_text_elem.className = "bold";

    var comment_text_elem = document.createElement('div');
    comment_text_elem.id = comment_div.id + "_text";
    comment_text_elem.className = "text";

    comment_div.appendChild(bold_text_elem);
    comment_div.appendChild(comment_text_elem);
    container_div.appendChild(comment_div);

    let response_color = capitalize_first_letter(turn_color(chess));
    let move_color = capitalize_first_letter(non_turn_color(chess));
    let ext_san = tree_get_node_string(move);
    let current_move = response_num == undefined;
    let before_start = current_move && move.move == undefined;
    let first_move = move.move_index == 0;
    let text = unescape_string(move.comments[0].text.trim());
    let bold_text = undefined;

    if (before_start) {
        bold_text = "";
    } else if (current_move) {
        bold_text = move_color + " " + ext_san + ":"
    } else {  // response move
        bold_text = response_color + " " + (!first_move ? i18n.response : "") + " " + ext_san + ":";
    }

    set_text(comment_div.id, text, { bold_text: bold_text });
}

function create_comment_list(container_id, current_move, response_moves) {
    let container_div = document.getElementById(container_id);
    container_div.innerHTML = '';

    if (current_move != undefined) {
        create_comment(container_div, undefined, current_move);
    }

    for (let [i, move] of response_moves.entries()) {
        create_comment(container_div, i, move, true);
    }
}

/*
 * Display comments, either only for the current move, or for the opposite side's responses as well
 * if that option is turned on.
 */
function display_comments(once) {
    let cm = tree_get_node(curr_move);
    let current_move = undefined;
    let response_moves = [];

    if (once || show_comments == i18n.comments_always_on ||
        show_comments == i18n.comments_when_arrows && give_hints(once)) {

        // Get current move if it has a comment
        if (cm.comments != undefined && cm.comments[0] != undefined && cm.comments[0].text != undefined) {
            current_move = cm;
        }
        // Get the reponse moves that has comments
        let children = tree_children(curr_move);
        if (children.length > 0) {
            for (let m of children) {
                if (m.comments != undefined && m.comments[0] != undefined && m.comments[0].text != undefined) {
                    response_moves.push(m);
                }
            }
        }
    }

    create_comment_list("comments", current_move, response_moves);
}

function change_play_stockfish() {
    let fen = chess.fen();
    let link = document.getElementById("play_stockfish");
    let base = link.href.split("#")[0];
    link.href = `${base}#${fen}`;
}

/**
 * Lichess.org has two ways of launching an analysis board. One is through a FEN and the other
 * is through a PGN and a color. The benefit of the PGN version is that it allows the user to 
 * step back through the move line and evaluate the position at any of the played moves. If the
 * repertoire doesn't start on move 1, ie it has a FEN code as a starting positionin the PGN
 * file, then using the PGN url doesn't work. So to utilize the possibility of the GN url when
 * we can, we use that url when the repoertoire starts at move 1, or else the FEN url.
 */
function change_analysis_board() {
    let link = document.getElementById("analysis_board");
    // The PGN standard requires a SetUp header when there is another start position
    let starts_midgame = trees[chapter].headers.SetUp != undefined;
    if (starts_midgame) {
        let fen = chess.fen();
        link.href = `https://lichess.org/analysis/${fen}`;
    } else {
        let pgn = encodeURIComponent(chess.pgn());
        let color = turn_color(chess);
        link.href = `https://lichess.org/analysis/pgn/${pgn}?color=${color}`;
    }
}

function setup_move() {
    change_play_stockfish();
    change_analysis_board();
    display_arrows(false);
    show_suggestions();
    display_comments(false);
    ground_set_moves(); // the legal moves of the position
}

/*
 * Returns the ai move that should be played for the access position
 */
function ai_move(access) {
    //console.log('Finding moves after ' + (tree_get_node(access).move_index > 0 ? tree_get_node_string(tree_get_node(access)) : 'starting position'));

    let candidates = tree_children_filter_sort(access, {filter: has_children});
    let m = tree_size_weighted_random_move(candidates);

    // change the last updated value of the node so if other moves exists they will be
    // picked next time instead
    if (m !== undefined) {
        update_value(access, 1, m);
    }
    return m;
}

/*
 * Plays a move in san notation
 * Update chess, ground, access
 */
function play_move(san) {
    let m = chess.move(san);
    ground_move(m);
    curr_move.push(tree_move_index(curr_move, san));
}

function start_training() {
    window.curr_move = [chapter];
    window.first_variation = trees[chapter].first_variation;
    // this fen is the normal chess starting position
    let fen = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1";
    if ("headers" in trees[chapter]) {
        fen = trees[chapter].headers.FEN || fen;
    }
    setup_chess(fen);
    ground_init_state(fen);
    if (key_moves_mode == i18n.key_move_enabled && window.first_variation !== null) {
        for (let ki = 0; ki < window.first_variation; ++ki) {
            // Moves that are not fully trained are not skipped
            if (tree_children(curr_move)[0].value != 5) { break; }
            // Multiple moves are played without delay, causes distorted sound
            // sound_enabled controls if sound is played in sound.js
            // the sounds are initiated by ground.move which is used by play_move
            let stored_sound = sound_enabled;
            sound_enabled = false;
            play_move(ai_move(curr_move));
            sound_enabled = stored_sound;
        }
    }
    if (color != turn_color(chess)) {
        play_move(ai_move(curr_move));
    }
    setup_move();

    /* TODO figure out how to remove this. This is a workaround to make sure arrows appear right from
    the start. Without this, setShapes() in display_arrows() appear to have no effect. It's only needed the
    first time hints are displayed, so this is a good location. The redraw scrolls the page to the top
    on mobile devices, and having the call in display_arrows() then forces a scroll to the top every time
    the user makes a move or changes the Arrows option. Hours have been spent on this bug. Could be a
    bug in chessground. */
    ground.redrawAll();

    window.mode = mode_free;
}

/*
 * Store the trees in window.trees into localStorage
 */
function store_trees() {
    let tree_key = study_id + "_tree";
    localStorage.setItem(tree_key, JSON.stringify(trees));
}

// load the trees from the localStorage or generate if they dont exist
function setup_trees() {
    let hash_key = study_id + "_hash";
    let tree_key = study_id + "_tree";

    let last_hash = localStorage.getItem(hash_key);
    let curr_hash = string_hash(pgn + color);
    curr_hash += 3; // increase when trees have to be redone; for example when bugs in free_from_pgn are fixed
    let trees = {};

    if (last_hash == undefined || curr_hash != last_hash) {
        const pgnParser = require('pgn-parser'); // slows down page load, so only require if actually needed
        try {
            const parsedpgn = pgnParser.parse(pgn);
            annotate_pgn(parsedpgn);
            trees = generate_move_trees(parsedpgn);
            clear_local_storage();
            localStorage.setItem(hash_key, curr_hash);
            localStorage.setItem(tree_key, JSON.stringify(trees));
        } catch(caught_error) {
            console.log(caught_error);
            let error_text = caught_error.name + " at line: " + caught_error.location.start.line +
                             ", character: " + caught_error.location.start.column + "; Unexpected: \"" +
                             caught_error.found + "\"";
            set_text(error_div, error_text);
        }
    } else {
        trees = JSON.parse(localStorage.getItem(tree_key));
    }
    window.trees = trees;
}

/*
 * Returns the name of the event or a generic Chapter 1 if no event is present
 */
function tree_chapter_name(tree_index) {
    return trees[tree_index].headers.Event || i18n.translation_chapter + " " + (tree_index+1);
}

// generate the chapter selection below the game board
// the chapter value is the id for the tree to use
function setup_chapter_select() {
    let select_key = study_id + "_selected";
    let select_id = "chapter_select"
    let select = document.getElementById(select_id);
    let selected = parseInt(localStorage.getItem(select_key) || 0);
    selected = Math.min(selected, trees.length - 1);  // prevent error if replacing with a pgn with fewer chapters
    window.chapter = selected;
    for (let i = 0; i < trees.length; ++i) {
        let option = document.createElement("option");
        option.value = i;
        let name = tree_chapter_name(i);
        option.innerText = name;
        if (i == selected) {
            option.selected = true;
        }
        select.appendChild(option);
    }

    select.onchange = function() {
        let v = document.getElementById(select_id).value;
        localStorage.setItem(select_key, v);
        window.chapter = v;
        start_training();
        update_progress(); // update the progress bar shown
        set_options_values_for_max_depth();  // update the max depth for the new chapter
    };
}

/*
 * Show suggestions based on the move number
 */
// function show_suggestions() {
//     let suggestions = [
//         {move: 15, show: true, text: i18n.suggestion_share, once: true, key: "share"},
//         {move: 30, show: logged_in, text: i18n.suggestion_favorite, once: true, key: "favorite"},
//         {move: 30, show: !logged_in, text: i18n.suggestion_account, once: false, key: "account"},
//         {move: 50, show: logged_in, text: i18n.suggestion_comment, once: true, key: "comment"},
//         {move: 100, show: true, text: i18n.suggestion_100moves, once: false, key: "100moves"},
//         {move: 250, show: true, text: i18n.suggestion_250moves, once: false, key: "250moves"}
//     ]

//     for (let suggestion of suggestions) {
//         let lsKey = study_id + "_suggestions_" + suggestion.key;
//         let alreadySuggested = localStorage.getItem(lsKey) || false;
//         if (total_moves == suggestion.move && suggestion.show && !(suggestion.once && alreadySuggested)) {
//             set_text(suggestion_div, suggestion.text);
//             localStorage.setItem(lsKey, true);
//         }
//     }
// }

function show_suggestions() {
    let suggestions = [
        {expr: function(){ return first_pgn_arrow_seen },       text: i18n.first_pgn_arrow_seen, once: false, key: "first_pgn_arrow"},
        {expr: function(){ return first_neglected_move_seen },  text: i18n.first_neglected_move_seen, once: false, key: "first_neglected_move"},
        {expr: function(){ return total_moves >= 15 },          text: i18n.suggestion_share, once: true, key: "share"},
        {expr: function(){ return total_moves >= 30 && logged_in },  text: i18n.suggestion_favorite, once: true, key: "favorite"},
        {expr: function(){ return total_moves >= 30 && !logged_in }, text: i18n.suggestion_account, once: false, key: "account"},
        {expr: function(){ return total_moves >= 50 && logged_in },  text: i18n.suggestion_comment, once: true, key: "comment"},
        {expr: function(){ return total_moves >= 100 },         text: i18n.suggestion_100moves, once: false, key: "100moves"},
        {expr: function(){ return total_moves >= 250 },         text: i18n.suggestion_250moves, once: false, key: "250moves"}
    ]

    console.log("total_moves: " + total_moves);
    console.log("seen_suggestions: " + seen_suggestions);
    
    for (let suggestion of suggestions) {
        let lsKey = study_id + "_suggestions_" + suggestion.key;
        let show_once = suggestion.once;
        let seen_ever = localStorage.getItem(lsKey) === "true";
        let seen_this_time = array_contains(seen_suggestions, suggestion.key);
        let show = (show_once && !seen_ever) || (!show_once && !seen_this_time);
        let expression = suggestion.expr();

        if (expression && show) {
            set_text(suggestion_div, suggestion.text);
            localStorage.setItem(lsKey, true);
            seen_suggestions.push(suggestion.key);
            break;  // only show one suggestion at a time
        }
    }
}

function setup_intro() {
    set_text(info_div, i18n.info_intro);

    let roots = trees.map(x => x.root[0]);
    let max = Math.max(...roots.map(x => tree_value(x, Math.max)));

    if (max == 0 && show_arrows != i18n.arrows_hidden) {
        set_text(suggestion_div, i18n.info_arrows);
    }
}

function turn_on_hints_for_current_move() {
    display_arrows(true);
    display_comments(true);
}

function toggle_arrows() {
    let span = document.getElementById("arrows_toggle");
    let curr = span.textContent;
    switch (curr) {
        case i18n.arrows_new2x:
            curr = i18n.arrows_new5x;
            break;
        case i18n.arrows_new5x:
            curr = i18n.arrows_always;
            break;
        case i18n.arrows_always:
            curr = i18n.arrows_hidden;
            break;
        case i18n.arrows_hidden:
        default:
            curr = i18n.arrows_new2x;
            break;
    }
    span.textContent = curr;
    show_arrows = curr;
    display_arrows(false);
    display_comments(false);
    localStorage.setItem(show_arrows_key, show_arrows);
}

function toggle_arrow_type() {
    let span = document.getElementById("arrow_type");
    let curr = span.textContent;
    switch (curr) {
        case i18n.arrow_type_auto:
            curr = i18n.arrow_type_pgn;
            break;
        case i18n.arrow_type_pgn:
            curr = i18n.arrow_type_both;
            break;
        case i18n.arrow_type_both:
        default:
            curr = i18n.arrow_type_auto;
            break;
    }
    span.textContent = curr;
    arrow_type = curr;
    display_arrows(false);
    display_comments(false);
    localStorage.setItem(arrow_type_key, arrow_type);
}

function toggle_key_move() {
    let link = document.getElementById("key_move");
    let curr = link.textContent;
    switch (curr) {
        case i18n.key_move_enabled:
            curr = i18n.key_move_disabled;
            link.setAttribute("data-icon", "%");
            break;
        case i18n.key_move_disabled:
        default:
            curr = i18n.key_move_enabled;
            link.setAttribute("data-icon", "$");
            break;
    }
    key_moves_mode = curr;
    link.textContent = curr;
    localStorage.setItem(key_moves_mode_key, key_moves_mode);
}

function toggle_review() {
    let link = document.getElementById("line_review");
    let curr = link.textContent;
    switch (curr) {
        case i18n.review_fast:
            curr = i18n.review_slow;
            break;
        case i18n.review_slow:
        default:
            curr = i18n.review_fast;
            break;
    }
    board_review = curr;
    link.textContent = curr;
    localStorage.setItem(board_review_key, board_review);
}

function toggle_move_delay() {
    let span = document.getElementById("move_delay_time");
    let curr = span.textContent;
    switch (curr) {
        case i18n.instant:
            curr = i18n.fast;
            break;
        case i18n.fast:
            curr = i18n.medium;
            break;
        case i18n.medium:
            curr = i18n.slow;
            break;
        case i18n.slow:
        default:
            curr = i18n.instant;
            break;
    }
    span.textContent = curr;
    move_delay_time = curr;
    localStorage.setItem(move_delay_time_key, move_delay_time);
}


function get_move_delay() {
    let delay = 300;
    switch (move_delay_time) {
        case i18n.instant:
            delay = 300;
            break;
        case i18n.fast:
            delay = getRandomIntFromRange(500, 1500);
            break;
        case i18n.medium:
            delay = getRandomIntFromRange(1500, 3000);
            break;
        case i18n.slow:
            delay = getRandomIntFromRange(5000, 10000);
            break;
        default:
            console.log("Got non supported move delay: ", move_delay_time);
            delay = 300;
    }
    return delay;
}

function toggle_comments() {
    let link = document.getElementById("comments_toggle");
    let curr = link.textContent;
    switch (curr) {
        case i18n.comments_always_on:
            curr = i18n.comments_hidden;
            break;
        case i18n.comments_hidden:
            curr = i18n.comments_when_arrows;
            break;
        case i18n.comments_when_arrows:
        default:
            curr = i18n.comments_always_on;
            break;
        }
    link.textContent = curr;
    show_comments = curr;
    display_comments(false);
    localStorage.setItem(show_comments_key, show_comments);
}

function get_repertoire_depth() {
    let starting_moves = trees[chapter].root;
    let for_white = color == "white";
    return tree_max_num_moves_deep(starting_moves, for_white);
}

/**
 * Update option label with a new max depth.
 */
 function update_max_depth_label(depth, tree_depth) {
    let max_depth_container = document.getElementById("max_depth_container");
    let max_depth_label = document.getElementById("max_depth_label");

    max_depth_label.innerText = depth;
    if (depth == tree_depth) {
        max_depth = DEPTH_MAX;
        max_depth_container.classList.remove("option-highlighted");
    } else {
        max_depth = depth;
        max_depth_container.classList.add("option-highlighted");
    }
}

/**
 * User clicked on the + or - next to the max depth range control.
 */
function inc_or_dec_max_depth(delta) {
    let max_depth_range = document.getElementById("max_depth_range");
    let tree_depth = get_repertoire_depth();
    let depth = parseInt(max_depth_range.value, 10) || tree_depth;

    depth += delta;
    // Make sure it's not lower than 1 or higher than the actual depth of the tree
    depth = delta > 0 ? Math.min(depth, tree_depth) : Math.max(depth, 1);
    max_depth_range.value = depth;

    update_max_depth_label(depth, tree_depth);

    localStorage.setItem(max_depth_key_base + chapter, max_depth);
}

/**
 * User dragged the max depth range/slider control to a new value.
 */
function max_depth_changed() {
    let max_depth_range = document.getElementById("max_depth_range");
    let tree_depth = get_repertoire_depth();
    let depth = parseInt(max_depth_range.value, 10) || tree_depth;

    update_max_depth_label(depth, tree_depth);

    localStorage.setItem(max_depth_key_base + chapter, max_depth);
}

function reset_line() {
    start_training();
}

/*
 * Updates the progress modal html
 */
async function update_progress() {
    let d = document.getElementById("study_progress");
    d.innerHTML = "";

    for (let tree_index in trees) {
        let chapter_name = tree_chapter_name(tree_index);
        let tree = trees[tree_index];
        let progress = tree_progress(trees[tree_index].root[0]);
        let percent = parseInt( (progress[0] / progress[1]) * 100);
        let name = document.createElement("b");
        name.innerText = `${chapter_name} (${percent}%)`;
        d.appendChild(name);
        d.innerHTML += `
        <div class="progress-bar">
            <span id="progress" class="progress-bar-fill" style="width: ${percent}%;"></span>
        </div>
        `
    }

    let cp = document.getElementById("chapter_progress");
    let chapter_index = parseInt(chapter);
    let progress = tree_progress(trees[chapter].root[0]);
    let percent = parseInt( (progress[0] / progress[1]) * 100);
    cp.innerHTML = `
    <div class="progress-bar" title="${percent}%">
        <span id="progress" class="progress-bar-fill" style="width: ${percent}%;"></span>
    </div>
    `
}

async function setup_progress_reset() {
    let reset = document.getElementById("study_progress_reset");
    reset.onclick = function() {
        if (window.confirm(i18n.confirm_reset_progress)) {
            for (let c of trees) {
                tree_value_add(c.root[0], -5);
            }
            store_trees();
            update_progress();
            display_arrows(false);
            display_comments(false);
        }
    }
}

/**
 * Initiate all option labels on the page.
 */
function set_options_values() {
    let move_delay = document.getElementById("move_delay_time");
    move_delay.innerText = move_delay_time;

    let arrows_toggle = document.getElementById("arrows_toggle");
    arrows_toggle.innerText = show_arrows;

    let arrow_type_toggle = document.getElementById("arrow_type");
    arrow_type_toggle.innerText = arrow_type;

    let line_review = document.getElementById("line_review");
    line_review.innerText = board_review;

    let key_move = document.getElementById("key_move");
    key_move.innerText = key_moves_mode;
    key_move.setAttribute("data-icon", key_moves_mode == i18n.key_move_enabled ? "$" : "%");

    let comments_toggle = document.getElementById("comments_toggle");
    comments_toggle.innerText = show_comments;

    set_options_values_for_max_depth();
}

function set_options_values_for_max_depth() {
    let max_depth_key = max_depth_key_base + chapter;
    max_depth = get_option_from_localstorage(max_depth_key, DEPTH_MAX, undefined, {validate: Number.isInteger, transform: parseInt});

    let tree_depth = get_repertoire_depth();
    let max_depth_range = document.getElementById("max_depth_range");
    let depth_as_num = max_depth == DEPTH_MAX ? tree_depth : max_depth;
    let depth = Math.min(tree_depth, depth_as_num);
    max_depth_range.max = tree_depth;
    max_depth_range.value = depth;
    max_depth_range.disabled = (tree_depth == 1);

    update_max_depth_label(depth, tree_depth);
}

function setup_configs() {
    document.getElementById("study_mainpage1").onclick = turn_on_hints_for_current_move;
    document.getElementById("study_mainpage3").onclick = turn_on_hints_for_current_move;
    document.getElementById("hints").onclick = turn_on_hints_for_current_move;
    document.getElementById("arrows_toggle").onclick = toggle_arrows;
    document.getElementById("arrow_type").onclick = toggle_arrow_type;
    document.getElementById("line_review").onclick = toggle_review;
    document.getElementById("move_delay").onclick = toggle_move_delay;
    document.getElementById("key_move").onclick = toggle_key_move;
    document.getElementById("comments_toggle").onclick = toggle_comments;
    document.getElementById("reset_line").onclick = reset_line;
    document.getElementById("max_depth_sub").onclick = () => inc_or_dec_max_depth(-1);
    document.getElementById("max_depth_add").onclick = () => inc_or_dec_max_depth(+1);
    document.getElementById("max_depth_range").onchange = max_depth_changed;
    document.getElementById("max_depth_range").oninput = max_depth_changed;
}

window.overlay_manager = new TextOverlayManager();

function main() {
    setup_ground();
    setup_chess();
    setup_trees();
    setup_chapter_select();
    set_options_values();
    setup_move_handler(handle_move);

    window.total_moves = 0;

    resize_ground();

    setup_intro();

    start_training();
    setup_configs();
    update_progress();
    setup_progress_reset();
}

window.onresize = onresize;
main();
