Feature("tactics");

Scenario("visit tactic", (I) => {
    I.amOnPage("/en/tactics");
    I.see("Tactic");
    I.seeElement({xpath: "//html/body/main/div/div/div[1]/div/cg-helper/cg-container"})
});
