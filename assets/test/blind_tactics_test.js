Feature("blind tactics");

Scenario("visit blind tactic", (I) => {
    I.amOnPage("/en/blind-tactics");
    I.see("7. e6 h6 8. Qf3 Qe8");
    I.seeElement({xpath: "//html/body/main/div/div/div[1]/div/cg-helper/cg-container"})
});
