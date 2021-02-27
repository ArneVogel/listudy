Feature("studies");

Scenario("create study from lichess study", ({ I }) => {
    I.amAcceptingPopups();
    I.amOnPage("/session/new");
    I.fillField("Email", "arne@listudy.org");
    I.fillField("Password", "temppass");
    I.click("Sign in", "//html/body/main/form/div/button");
    I.see("Welcome");
    I.amOnPage("/en/studies/new");
    I.fillField("Title", "This is an awesome Study");
    I.fillField("Description", "This is an awesome Study with an description");
    I.fillField("Lichess Study", "https://lichess.org/study/xTptRWc4");
    I.click("Save");
    I.see("Starting training");
    I.click("Edit");
    I.see("Edit Study");
    I.click("Delete");
    I.see("Study deleted successfully.");
});

Scenario("create study from file upload", ({ I }) => {
    I.amAcceptingPopups();
    I.amOnPage("/session/new");
    I.fillField("Email", "arne@listudy.org");
    I.fillField("Password", "temppass");
    I.click("Sign in", "//html/body/main/form/div/button");
    I.see("Welcome");
    I.amOnPage("/en/studies/new");
    I.fillField("Title", "This is an awesome Study");
    I.fillField("Description", "This is an awesome Study with an description");
    I.attachFile("Select a PGN to upload", "data/valid.pgn");
    I.click("Save");
    I.see("Starting training");
    I.click("Edit");
    I.see("Edit Study");
    I.click("Delete");
    I.see("Study deleted successfully.");
});

Scenario("study with error", ({ I }) => {
    I.amAcceptingPopups();
    I.amOnPage("/session/new");
    I.fillField("Email", "arne@listudy.org");
    I.fillField("Password", "temppass");
    I.click("Sign in", "//html/body/main/form/div/button");
    I.see("Welcome");
    I.amOnPage("/en/studies/new");
    I.fillField("Title", "This is an awesome Study");
    I.fillField("Description", "This is an awesome Study with an description");
    I.attachFile("Select a PGN to upload", "data/invalid.pgn");
    I.click("Save");
    I.see("SyntaxError");
    I.click("Edit");
    I.see("Edit Study");
    I.click("Delete");
    I.see("Study deleted successfully.");
});
