#!/bin/sh
npm install --legacy-peer-deps --prefix ./assets
npm run deploy --prefix ./assets
mix phx.digest
