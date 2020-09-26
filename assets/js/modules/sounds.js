class Sounds {
    constructor() {
        let ground_sources = {move: "/sounds/standard/Move.mp3", 
                              capture: "/sounds/standard/Capture.mp3"};
        let other_sources = {success: "/sounds/other/success.mp3",
                             error: "/sounds/other/error.mp3"}
        this.sounds = new Map();
        for (let key in ground_sources) {
            let a = new Audio(ground_sources[key]);
            a.preload = "auto";
            a.load();
            this.sounds.set(key, a);
        }
        for (let key in other_sources) {
            let a = new Audio(other_sources[key]);
            a.preload = "auto";
            a.load();
            this.sounds.set(key, a);
        }
    }

    play(sound) {
        if (sound_enabled == false) {return;}
        let s = this.sounds.get(sound);
        if (s == undefined) {return;}
        // copy the sound to allow for rapid replaying of the same sound
        s = s.cloneNode(); 
        s.volume = Number(sound_volume);
        s.play();
    }
}

const sounds = new Sounds();
export { sounds };
