Feature("endgames");

Scenario("visit a endgame", (I) => {
    I.amOnPage("/en");
    I.click("Endgames");
    I.see("Endgames");
    I.click("Learn");
    I.see("Queen");
    I.click("1");
    I.see("White to play and win");
});
