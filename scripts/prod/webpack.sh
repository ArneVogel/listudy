#!/bin/sh
npm install --prefix ./assets
npm run deploy --prefix ./assets
mix phx.digest
