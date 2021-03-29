let div = `
<div class="doge-wrapper">
    <div class="with_sidebar">
        <div id="game_container" class="sidebar_main">
            <h5 class="doge-title">So Chess, Much DogeStudy!</h5>
            <p>Welcome to the future of chess. Wow!</p>
            <p>More features!</p>
            <p>Learn how to improve with <a class="doge-link" href="/en/features/dogestudy">DogeStudy</a></p>
        </div>
        <div class="sidebar">
            <div class="doge-logo"></div>
        </div>
    </div>

<p></p>
</div>`;
if (document.URL.indexOf("studies") != -1) {
    let wrapper = document.createElement('div');
    wrapper.innerHTML = div;
    document.getElementsByTagName("main")[0].prepend(wrapper);
}
