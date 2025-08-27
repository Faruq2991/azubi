#!/bin/sh
set -e

DB_HOST=mysql
DB_PORT=3306

echo "Waiting for database connection..."
while ! nc -z $DB_HOST $DB_PORT; do
  sleep 1
done
echo "Database is ready!"

# Run database migrations
php artisan migrate --force

# Run database seeders
php artisan db:seed --force

# Execute the main container command (php-fpm)
exec "$@"