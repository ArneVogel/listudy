import { sounds } from './../modules/sounds.js';

// load the values or set default
let sound_volume_key = "sound_volume";
let sound_enabled_key = "sound_enabled";
window.sound_volume = localStorage.getItem(sound_volume_key) || 0.7;
localStorage.setItem(sound_volume_key, sound_volume);
window.sound_enabled = localStorage.getItem(sound_enabled_key) || true;
localStorage.setItem(sound_enabled_key, sound_enabled);

// turn the string localStorage returns back into a boolean
if (sound_enabled == "true") { sound_enabled = true; }
if (sound_enabled == "false") { sound_enabled = false; }

let enable_input = document.getElementById("sound_enable");
let volume_input = document.getElementById("sound_volume");

// set the inputs to the actual values
if (enable_input != null) {
    enable_input.checked = sound_enabled;

    // on change set the localStorage values and update values
    enable_input.addEventListener('change', (event) => {
        sound_enabled = enable_input.checked;
        localStorage.setItem(sound_enabled_key, sound_enabled);
    });
}
if (volume_input != null) {
    volume_input.value = sound_volume;

    volume_input.addEventListener('change', (event) => {
        sound_volume = volume_input.value;
        localStorage.setItem(sound_volume_key, sound_volume);
    });
}

let test_buttons = [["sound_move", "move"], ["sound_capture", "capture"], 
                    ["sound_success", "success"], ["sound_error", "error"]];
for (let b of test_buttons) {
    let el = document.getElementById(b[0]);
    if (el != null) {
        el.addEventListener("click", () => {
            sounds.play(b[1]);
        })
    }
}

