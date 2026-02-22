#!/bin/sh
./scripts/prod/compile.sh
./scripts/prod/webpack.sh
./scripts/prod/migrate.sh
./scripts/prod/stop_server.sh
./scripts/prod/start_server.sh
