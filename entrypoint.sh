#!/bin/bash
set -e

# Remove a potentially pre-existing server.pid for Rails
rm -f /app/tmp/pids/server.pid

# Create tmp directories if they don't exist
mkdir -p /app/tmp/pids
mkdir -p /app/tmp/cache
mkdir -p /app/log

# Wait for database to be ready
until nc -z -v -w30 db 5432
do
  echo 'Waiting for PostgreSQL...'
  sleep 1
done
echo "PostgreSQL is up and running!"

# Run database migrations
bundle exec rails db:migrate
echo "Database migrations completed!"

# Precompile assets
echo "Precompiling assets..."
bundle exec rails assets:precompile
echo "Assets precompiled!"

# Execute the main process
exec "$@"
