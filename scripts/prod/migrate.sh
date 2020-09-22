#!/bin/sh
. ./scripts/prod/env.sh
mix ecto.migrate
