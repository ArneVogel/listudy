# Listudy
Listudy is a application for chess training.

## Contribute
### Bugs
If you find any bugs, please let me know. You can submit bugs here: https://github.com/ArneVogel/listudy/issues
### Translations
Help with translations if you can. You find the current translations [here](https://github.com/ArneVogel/listudy/tree/master/priv/gettext). 
If you want to help with a language that is not currently avaliable message me or create a [issue](https://github.com/ArneVogel/listudy/issues) and I will create the language. 

This project used gettext for translations. Gettext uses PO files for translations ([example](https://github.com/ArneVogel/listudy/blob/master/priv/gettext/de/LC_MESSAGES/default.po)). In these files the original english sentence or phrase `msgid` is above what the translation should be `msgstr`. Only edit `msgstr` in the PO files. Sometimes special sequences like `%{name}` are in the english text. These must be copied exactly (not translated) into the translation.  

## Development
Listudy is developed in Elixir using the phoenix framework. It uses postgresql as database. You can checkout `scripts/prod/*.sh` for how the server is run in production.

To generate opening svg images Python3.8 is used together with [python-chess](https://github.com/niklasf/python-chess). This should be optional.

To start the server:
  * You need to [install Elixir](https://elixir-lang.org/install.html), [install npm](https://www.npmjs.com/get-npm), and [PostgreSQL](https://www.postgresql.org/download). The DB user and password for Postgres should be 'postgres' (no quotes).
  * Setup the project with `mix setup`
  * Install npm dependencies with `npm install --prefix assets`. For Windows, you need to run `cd assets` then `npm install` then `cd ..`.
  * Make study pgn directory with `mkdir priv/static/study_pgn`
  * Opening svg directory with `mkdir priv/static/images/opening`
  * Create database with `mix ecto.create`, migrate databse with `mix ecto.migrate`, fill database with seed dataset `mix run priv/repo/seeds.exs`
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

