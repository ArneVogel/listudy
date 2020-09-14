Feature("login");

Scenario("valid login", (I) => {
    I.amOnPage("/en");
    I.click("Sign in");
    I.see("Password");
    I.fillField("Email", "arne@listudy.org");
    I.fillField("Password", "temppass");
    I.click("Sign in", "//html/body/main/form/div/button");
    I.see("Welcome to Listudy");
});

Scenario("invalid login", (I) => {
    I.amOnPage("/en");
    I.click("Sign in");
    I.see("Password");
    I.fillField("Email", "arne@listudy.org");
    I.fillField("Password", "thisisnotthepass");
    I.click("Sign in", "//html/body/main/form/div/button");
    I.see("The provided login details did not work. Please verify your credentials, and try again.");
});
