Feature('homepage');

Scenario('homepage loads', (I) => {
  I.amOnPage('/en');
  I.see('Listudy');
});

Scenario('click login', (I) => {
  I.amOnPage('/en');
  I.click('Sign in');
  I.see('Password');
});
