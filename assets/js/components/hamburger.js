document.addEventListener('DOMContentLoaded', function () {
    let hamburger = document.getElementById('hamburger');
    if (hamburger != null) {hamburger.addEventListener('click', toggle_hamburger );}
    let back_buttons = document.getElementsByClassName("go-back");
    for (let b of back_buttons) {
        b.addEventListener('click', () => {
            history.back();
        });
    }
});
function toggle_hamburger() {
    function toggle(divs) {
        for (let i = 0; i < divs.length; ++i) {
            divs[i].classList.toggle("show");
        }
    }
    document.getElementById("hamburger").classList.toggle("hamburger_toggle");
    toggle(document.getElementsByClassName("dropdowns_container"));
    toggle(document.getElementsByClassName("nav_element"));
    toggle(document.getElementsByClassName("logo"));
} 
