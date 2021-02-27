Feature("play-stockfish");

Scenario("visit stockfish", ({ I }) => {
    I.amOnPage("/en/play-stockfish");
    I.see("Stockfish");
});
