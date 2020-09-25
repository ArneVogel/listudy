class Sounds {
    constructor() {
        let sources = {move: "/sounds/standard/Move.mp3", 
                      capture: "/sounds/standard/Capture.mp3"};
        this.sounds = new Map();
        for (let key in sources) {
            let a = new Audio(sources[key]);
            a.preload = "auto";
            a.load();
            this.sounds.set(key, a);
        }
    }

    play(sound) {
        let s = this.sounds.get(sound);
        if (s == undefined) {return;}
        // copy the sound to allow for rapid replaying of the same sound
        s = s.cloneNode(); 
        s.play();
    }
}

const sounds = new Sounds();
export { sounds };
