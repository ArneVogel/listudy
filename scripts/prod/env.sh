#!/bin/sh

# environment variables for production

export PORT=4000
# these variables are only read for prod
export MIX_ENV=prod
# generate your own secret with: mix phx.gen.secret
export SECRET_KEY_BASE=CHANGE_THIS_Ax1nJt52LzAPVFNUc9Wp7Ux6JF0C4toh/JdnK6iXZQgR5hsXH4SCTBsC/COjEsj/
# database url for my dev server
export DATABASE_URL=postgresql://postgres:postgres@localhost:5432/listudy_dev
