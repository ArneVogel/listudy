
//We only need the site header
lines = pgn.split("\n").filter(line => line.startsWith("[Site \"")); 
// remove the [Site " "] from the site
lines = lines.map(site => site.split(" ")[1].replace(new RegExp("^\""), "").replace(new RegExp("\"]$"), ""));
// we only care about lichess urls
lines = lines.filter(site => site.startsWith("https://lichess.org/study/"));
// remove the chapter part
lines = lines.map(function(site) {
    s = site.split("/");
    s.pop(); // pop returns the popped element and updates the array
    return s.join("/")
})

if (lines.length > 0) {
    lichess_url = lines[0];
    document.getElementById("study_lichess_study").value = lichess_url;
}
