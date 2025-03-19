#!/bin/sh

set -e

echo "ENV:" $ENV_VALUE

# Set RAILS_ENV if ENV_VALUE is provided
if [ -n "$ENV_VALUE" ]; then
  export RAILS_ENV="$ENV_VALUE"
else
  export RAILS_ENV="production"
fi

# Function to start Rails server
start_rails() {
  echo "Running database migrations..."
  bundle exec rake db:migrate
  
  echo "Starting Rails server..."
  exec rails server -b 0.0.0.0 
}

# Function to start shoryuken
start_shoryuken() {
  echo "Starting shoryuken..."
  exec bundle exec shoryuken -R -C config/shoryuken.yml
}

# Determine which process to run based on the first argument
case "$1" in
  shoryuken)
    start_shoryuken
    ;;
  *)
    start_rails
    ;;
esac
