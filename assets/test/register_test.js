Feature("register");

Scenario("invalid register", (I) => {
    I.amOnPage("/en");
    I.click("Register");
    I.fillField("Username", "a");
    I.fillField("Email", "invalid");
    I.fillField("Password", "abcdefg");
    I.click("Register", "//html/body/main/form/div/button");
    I.see("has invalid format");
    I.see("should be at least 8 character(s)");
});