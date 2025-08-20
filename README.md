## CLM System Monorepo

This repository contains the CLM backend API (Laravel 11, PHP 8.2) and the CLM web frontend (Next.js 15, React 18).

### Stack
- **Backend**: Laravel 11, Sanctum, PostgreSQL (default), Vite for assets
- **Frontend**: Next.js 15 (Pages Router), next-iron-session, TailwindCSS
- **Containerization**: Frontend Dockerfile using Next.js standalone output

### Repository structure
- `back-end/` – Laravel API
- `front-end/` – Next.js web app

## Prerequisites
- Node.js 18+ and npm
- PHP 8.2+, Composer
- PostgreSQL 13+ (or MySQL/MariaDB if you change `DB_CONNECTION`)

## Quick start (local development)

### 1) Backend (Laravel)
```bash
cd back-end
cp .env.example .env   # if present; otherwise create and fill values below
composer install
npm ci                  # for Vite/Tailwind assets
php artisan key:generate
# configure your DB in .env, then
php artisan migrate --seed

# Start dev services (server, queue worker, logs, vite) in one command
composer run dev
# or run individually:
# php artisan serve
# php artisan queue:listen --tries=1
# npm run dev
```

Backend runs at `http://localhost:8000` by default.

### 2) Frontend (Next.js)
```bash
cd front-end
cp .env.example .env.local  # if provided; otherwise create and set vars below
npm ci
npm run dev
```

Frontend runs at `http://localhost:3000`.

## Environment variables

### Backend (`back-end/.env`)
Minimal configuration for PostgreSQL (default):
```
APP_NAME=CLM
APP_ENV=local
APP_KEY=base64:...            # php artisan key:generate sets this
APP_DEBUG=true
APP_URL=http://localhost:8000

LOG_CHANNEL=stack

DB_CONNECTION=pgsql
DB_HOST=127.0.0.1
DB_PORT=5432
DB_DATABASE=clm
DB_USERNAME=postgres
DB_PASSWORD=postgres

QUEUE_CONNECTION=database
CACHE_STORE=file
FILESYSTEM_DISK=public

# If using Redis
# REDIS_HOST=127.0.0.1
# REDIS_PORT=6379
```

Note: The default DB connection in `config/database.php` is `pgsql`. Switch to MySQL/MariaDB by updating `DB_CONNECTION` and related values.

### Frontend (`front-end/.env.local`)
```
# URL to the backend app root (without trailing slash). The app will call ${BACKEND_API_HOST}/api
BACKEND_API_HOST=http://localhost:8000

# Secret for next-iron-session (32+ characters recommended)
SECRET_COOKIE_PASSWORD=please-change-this-to-a-strong-secret-string
```

These variables are used server-side (API routes and `getServerSideProps`). Public `NEXT_PUBLIC_*` variables are not required by default.

## Docker (Frontend)
The frontend is prepared for containerized production using Next.js standalone output.

Build and run:
```bash
docker build -t clm-web:latest -f front-end/Dockerfile front-end
docker run --rm -p 3000:3000 --name clm-web \
  -e BACKEND_API_HOST=http://host.docker.internal:8000 \
  -e SECRET_COOKIE_PASSWORD=change-me-please-32-chars-min \
  clm-web:latest
```

Then open `http://localhost:3000`.

Notes:
- The Docker image uses the Next.js standalone output (`.next/standalone`) and runs `node server.js`.
- Ensure the backend is reachable from the container. On Linux, replace `host.docker.internal` with your host IP if needed.

## Docker Compose (Frontend + Backend)

Use Docker Compose to run the full stack: Nginx + PHP-FPM (Laravel), MySQL, and the Next.js frontend.

### 1) Configure backend environment
Create `back-end/.env` (or update existing) with DB settings that match `docker-compose.yml`:

```
APP_NAME=CLM
APP_ENV=local
APP_KEY=
APP_DEBUG=true
APP_URL=http://localhost:8000

LOG_CHANNEL=stack

DB_CONNECTION=mysql
DB_HOST=mysql
DB_PORT=3306
DB_DATABASE=clm
DB_USERNAME=clm_user
DB_PASSWORD=clm_user
```

### 2) Bring services up
```bash
docker compose up -d --build
```

Services:
- Frontend: `http://localhost:3000` (container `frontend`)
- Backend API: `http://localhost:8000` (containers `backend-nginx` → `backend-php`)
- MySQL: exposed on `localhost:3306` (container `mysql`)

The frontend in Compose uses these env vars (see `docker-compose.yml`):
- `BACKEND_API_HOST=http://backend-nginx` (internal service URL)
- `SECRET_COOKIE_PASSWORD=a-very-secure-secret-for-cookie-encryption`

### 3) Initialize Laravel
Run the following once after containers start (or when the DB is reset):
```bash
docker compose exec backend-php php artisan key:generate
docker compose exec backend-php php artisan migrate --seed
```

If you change `.env`, clear config cache:
```bash
docker compose exec backend-php php artisan config:clear
```

### 4) Default login credentials
The database seeder creates a default admin user (see `back-end/database/seeders/UserTableSeeder.php`):

- Username: `admin`
- Password: `admin`
- Email: `admin@clms.com` (login uses username, not email)

### 5) Useful commands
- View logs:
  ```bash
  docker compose logs -f --tail=200 backend-nginx backend-php mysql frontend
  ```
- Stop services:
  ```bash
  docker compose down
  ```
- Stop and remove volumes (reset DB data):
  ```bash
  docker compose down -v
  ```

### 6) Troubleshooting
- Access denied for DB user: ensure `back-end/.env` matches `DB_*` values in `docker-compose.yml` (database `clm`, user `clm_user`, password `clm_user`). If MySQL was initialized with different creds, run `docker compose down -v` to reset the volume and start again.
- Frontend cannot reach backend: the container uses `BACKEND_API_HOST=http://backend-nginx`. From the browser, use `http://localhost:3000` which talks to `http://localhost:8000` through the network.

## Useful scripts

### Backend
- `composer run dev` – Runs Laravel server, queue worker, pail logs, and Vite dev server concurrently
- `php artisan migrate` – Applies DB migrations
- `npm run dev` – Runs Vite for asset bundling

### Frontend
- `npm run dev` – Start Next.js dev server
- `npm run build` – Production build
- `npm start` – Start production server (used inside the container via `node server.js`)

## API overview
Base URL: `${APP_URL}/api` (default `http://localhost:8000/api`)

Common endpoints:
- `GET /api/health` – health check
- `POST /api/login` – returns `{ user, api_token }` on success
- Authenticated routes (Bearer token via `Authorization: Bearer <api_token>`):
  - `PATCH /api/users/{user}/change-password`
  - `PATCH /api/users/{user}`
  - `GET/POST/DELETE /api/admin/users` (resource)

## Troubleshooting
- Frontend cannot reach backend: verify `BACKEND_API_HOST` and CORS settings on the backend (`APP_URL`, `CORS_ALLOWED_ORIGINS`).
- Session errors: ensure `SECRET_COOKIE_PASSWORD` is set and long enough (32+ characters).
- DB connection errors: confirm DB service is running and `back-end/.env` values match your local DB.

## License
Proprietary – internal use.