Feature("register");

Scenario("invalid register", ({ I }) => {
    I.amOnPage("/en");
    I.click("Register");
    I.fillField("Username", "a");
    I.fillField("Email", "invalid");
    I.fillField("Password", "abcdefg");
    I.fillField("Password confirmation", "abcdefg");
    I.click("Register", "//html/body/main/div/div[1]/form/div/button");
    I.see("should be at least 3 character(s)");
    I.see("has invalid format");
    I.see("should be at least 8 character(s)");
});

Scenario("valid register + deletion", ({ I }) => {
    I.amOnPage("/en");
    I.click("Register");
    I.fillField("Username", "abcd");
    I.fillField("Email", "valid@listudy.org");
    I.fillField("Password", "abcdefgf");
    I.fillField("Password confirmation", "abcdefgf");
    I.click("Register", "//html/body/main/div/div[1]/form/div/button");
    I.see("Welcome to Listudy!");
    I.amOnPage("/registration/edit");
    I.see("Edit profile");
    I.click("Close Account");
    I.see("Your account has been deleted. Sorry to see you go!");
});
