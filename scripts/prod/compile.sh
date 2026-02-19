#!/bin/sh
. ./scripts/prod/env.sh
mix deps.get
mix compile
