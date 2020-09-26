let modals = document.getElementsByClassName("modal");
let openers = document.getElementsByClassName("modal_open");
let closers = document.getElementsByClassName("modal_close");


for (let o of openers) {
    o.onclick = function() {
        let modal = document.getElementById(o.id + "_modal")
        modal.style.display = "block";
    }
}

for (let c of closers) {
    c.onclick = function() {
        for (let m of modals) {
            m.style.display = "none";
        }
    }
}

window.onclick = function(event) {
    for (let m of modals) {
        if (event.target == m) {
            m.style.display = "none";
        }
    }
} 
