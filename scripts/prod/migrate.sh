#!/bin/sh
. ./scripts/prod/env.sh
mix ecto.create
mix ecto.migrate
