class Achievement {
    constructor(name, description, key, hide) {
        this.name = name;
        this.description = description;
        this.key = key;
        this.hide = hide;
        this.solved = !!localStorage.getItem("achievement_" + key);

        if (!this.solved) {
            this.test();
        }
    }

    unlock() {
        if (!this.solved) {
            this.solved = true;
            localStorage.setItem("achievement_" + this.key, new Date());
            this.show_popup();
        }
    }

    show_popup() {
        let container = document.createElement("div");
        container.classList.add("popup");

        let close = document.createElement("span");
        close.innerText = "×";
        close.addEventListener("click", () => {
            container.classList.add("hidden");
        })

        let help = document.createElement("span");
        help.innerText = "?";
        help.addEventListener("click", () => {
            let lang = document.location.pathname.split("/")[1];
            let origin = document.location.origin;
            let p = `${origin}/${lang}/achievements`;
            window.location = p;
        });

        let headline = document.createElement("h2");
        headline.innerText = this.name;
        let text = document.createElement("p");
        text.innerText = this.description;

        container.appendChild(close);
        container.appendChild(help);
        container.appendChild(headline);
        container.appendChild(text);
        document.body.appendChild(container);
        window.setTimeout(function() {
            container.classList.add("hidden");
        }, 15000);
    }

    div() {
        let container = document.createElement("div");
        if (this.hide && !this.solved) {
            return container;
        }
        container.classList.add("achievement_list_elem");
        if (!this.solved) {
            container.classList.add("achievement_unsolved");
        } else {
            container.classList.add("achievement_solved");
        }
        let headline = document.createElement("h2");
        headline.innerText = this.name;
        let text = document.createElement("p");
        text.innerText = this.description;

        container.appendChild(headline);
        container.appendChild(text);

        return container;
    }
}

class Konami extends Achievement {
    constructor() {
        super("Konami Code", "You know what to do.", "konami", false);
        this.cursor = 0;
    }

    test() {
        const KONAMI_CODE = [38, 38, 40, 40, 37, 39, 37, 39, 66, 65];
        document.addEventListener('keydown', (e) => {
            this.cursor = (e.keyCode == KONAMI_CODE[this.cursor]) ? this.cursor + 1 : 0;
            if (this.cursor == KONAMI_CODE.length) this.unlock();
        });
    }
}

class Newcomer extends Achievement {
    constructor() {
        super("Newcomer", "Visit multiple pages.", "newcomer", false);
    }

    test() {
        let visits = localStorage.getItem("achievements_total_visits");
        if (Number(visits) >= 3) {
            this.unlock();
        }
    }
}

class Endgames extends Achievement {
    constructor() {
        super("Endgame Winner", "Win 3 endgames against Stockfish", "endgames", false);
    }

    test() {
        let t = localStorage.getItem("achievements_endgames_solved");
        if (Number(t) >= 3) {
            this.unlock();
        }
    }
}

class Endgames2 extends Achievement {
    constructor() {
        super("Endgame Champion", "Win 27 endgames against Stockfish", "endgames2", true);
    }

    test() {
        let t = localStorage.getItem("achievements_endgames_solved");
        if (Number(t) >= 27) {
            this.unlock();
        }
    }
}

class Endgames3 extends Achievement {
    constructor() {
        super("Endgame Winner", "Win 81 endgames against Stockfish", "endgames3", true);
    }

    test() {
        let t = localStorage.getItem("achievements_endgames_solved");
        if (Number(t) >= 81) {
            this.unlock();
        }
    }
}

class BlindTactics extends Achievement {
    constructor() {
        super("Blind Tactics", "Solve 5 blind tactics", "blindtactics", false);
    }

    test() {
        let t = localStorage.getItem("achievements_blind_tactics_solved");
        if (Number(t) >= 5) {
            this.unlock();
        }
    }
}

class TacticsSolver extends Achievement {
    constructor() {
        super("Tactics Solver", "Solve 5 tactics", "tacticsolver", false);
    }

    test() {
        let t = localStorage.getItem("achievements_tactics_solved");
        if (Number(t) >= 5) {
            this.unlock();
        }
    }
}

class TacticsSolver2 extends Achievement {
    constructor() {
        super("Advanced Tactics Solver", "Solve 32 tactics", "tacticsolver2", true);
    }

    test() {
        let t = localStorage.getItem("achievements_tactics_solved");
        if (Number(t) >= 32) {
            this.unlock();
        }
    }
}

class TacticsSolver3 extends Achievement {
    constructor() {
        super("Great Tactic Solver", "Solve 256 tactics", "tacticsolver3", true);
    }

    test() {
        let t = localStorage.getItem("achievements_tactics_solved");
        if (Number(t) >= 256) {
            this.unlock();
        }
    }
}


class Student extends Achievement {
    constructor() {
        super("Student", "Learn 3 opening lines.", "student", false);
    }

    test() {
        window.achievement_student_test = new Event('achievement_student_test');

        document.addEventListener('achievement_student_test', () => {
            let t = localStorage.getItem("achievements_lines_learned");
            if (Number(t) >= 3) {
                this.unlock();
            }
        });
    }
}

class Student2 extends Achievement {
    constructor() {
        super("Good Student", "Learn 25 opening lines.", "student2", true);
    }

    test() {
        window.achievement_student2_test = new Event('achievement_student2_test');

        document.addEventListener('achievement_student2_test', () => {
            let t = localStorage.getItem("achievements_lines_learned");
            if (Number(t) >= 25) {
                this.unlock();
            }
        });
    }
}

class Student3 extends Achievement {
    constructor() {
        super("Great Student", "Learn 100 opening lines.", "student3", true);
    }

    test() {
        window.achievement_student3_test = new Event('achievement_student3_test');

        document.addEventListener('achievement_student3_test', () => {
            let t = localStorage.getItem("achievements_lines_learned");
            if (Number(t) >= 100) {
                this.unlock();
            }
        });
    }
}

class Student4 extends Achievement {
    constructor() {
        super("Honor Student", "Learn 500 opening lines.", "student4", true);
    }

    test() {
        window.achievement_student4_test = new Event('achievement_student4_test');

        document.addEventListener('achievement_student4_test', () => {
            let t = localStorage.getItem("achievements_lines_learned");
            if (Number(t) >= 500) {
                this.unlock();
            }
        });
    }
}



class NewsReader extends Achievement {
    constructor() {
        super("News Reader", "Read a blog post.", "newsreader", false);
    }

    test() {
        if (window.location.pathname.indexOf("/blog") != -1) {
            this.unlock();
        }
    }
}

class NightOwl extends Achievement {
    constructor() {
        super("Night Owl", "Shouldn't you be asleep yet?", "nightowl", false);
    }

    test() {
        let date = new Date();
        let hour = date.getHours();
        if (hour >= 0 && hour <= 5) {
            this.unlock();
        }
    }
}


class Empty extends Achievement {
    constructor() {
        super("name", "description", "key", false);
    }

    test() {
    }
}

function main() {
    let tv = localStorage.getItem("achievements_total_visits") || 0;
    localStorage.setItem("achievements_total_visits", Number(tv) + 1);

    let achievements = [Newcomer, TacticsSolver, TacticsSolver2, TacticsSolver3, 
                        Student, Student2, Student3, Student4, 
                        Endgames, Endgames2, Endgames3,
                        BlindTactics, NewsReader, Konami, NightOwl];

    let ac = document.getElementById("achievement_container");
    for (let a of achievements) {
        let instance = new a();
        if (ac != null) {
            ac.appendChild(instance.div());
        }
    }
}

window.addEventListener("load", main);
document.addEventListener("phx:update", main);
