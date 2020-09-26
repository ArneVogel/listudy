class Achievement {
    constructor(name, description, key) {
        this.name = name;
        this.description = description;
        this.key = key;
        this.solved = !!localStorage.getItem("achievement_" + key);

        if (!this.solved) {
            this.test();
        }
    }

    unlock() {
        this.solved = true;
        localStorage.setItem("achievement_" + this.key, new Date());
        this.show_popup();
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
        super("Konami", "You know what to do.", "konami");
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
        super("Newcomer", "Welcome back.", "newcomer");
    }

    test() {
        let visits = localStorage.getItem("achievements_total_visits");
        if (visits >= 3) {
            this.unlock();
        }
    }
}

window.addEventListener("load", function(event) {
    let tv = localStorage.getItem("achievements_total_visits") || 0;
    localStorage.setItem("achievements_total_visits", Number(tv) + 1);

    let achievements = [Newcomer, Konami];
    let ac = document.getElementById("achievement_container");
    for (let a of achievements) {
        let instance = new a();
        if (ac != null) {
            ac.appendChild(instance.div());
        }
    }
});
