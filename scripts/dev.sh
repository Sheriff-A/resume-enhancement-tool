#!/bin/bash
# Starts local Supabase, refreshes generated TypeScript types, and runs the
# Nuxt dev server. When you stop this (Ctrl+C), local Supabase is stopped
# automatically too, so the Docker containers don't keep running in the
# background after you're done developing.
set -e

cleanup() {
  echo ""
  echo "Stopping local Supabase..."
  npx supabase stop
}
trap cleanup EXIT

npx supabase start
npx supabase gen types typescript --local > types/database.types.ts
npx nuxt dev