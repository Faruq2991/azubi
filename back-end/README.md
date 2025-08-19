## CLM API (Laravel 11)

Backend API for the CLM system built with Laravel 11 and PHP 8.2.

### Requirements
- PHP 8.2+
- Composer
- PostgreSQL (default) or MySQL/MariaDB
- Node.js 18+ and npm (for Vite assets)

### Setup
```bash
composer install
cp .env.example .env   # if the example is not present, create .env manually
php artisan key:generate

# configure DB credentials in .env, then
php artisan migrate --seed

# install and run vite dev (optional for local UI assets)
npm ci
npm run dev

# run the app
php artisan serve
```

Visit `http://localhost:8000`.

### Useful
- `composer run dev` – runs serve, queue:listen, pail logs, and vite concurrently
- Health check: `GET /api/health`

### Testing
```bash
phpunit
```
