Feature("blind tactics");

Scenario("visit blind tactic", (I) => {
    I.amOnPage("/en/blind-tactics");
    I.see("e6 h6 Qf3 Qe8");
    I.seeElement({xpath: "//html/body/main/div/div/div[1]/div/cg-helper/cg-container"})
});
