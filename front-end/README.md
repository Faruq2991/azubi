## CLM Web (Next.js 15)

Next.js 15 web portal for the CLM system.

### Requirements
- Node.js 18+
- npm

### Environment
Create `./.env.local`:
```
BACKEND_API_HOST=http://localhost:8000
SECRET_COOKIE_PASSWORD=change-me-please-32-chars-min
```

### Development
```bash
npm ci
npm run dev
```
Dev server: `http://localhost:3000`

### Production build
```bash
npm run build
npm start
```

### Docker (production)
```bash
docker build -t clm-web:latest -f Dockerfile .
docker run --rm -p 3000:3000 \
  -e BACKEND_API_HOST=http://host.docker.internal:8000 \
  -e SECRET_COOKIE_PASSWORD=change-me-please-32-chars-min \
  clm-web:latest
```

### Notes
- Uses `next-iron-session`; the cookie secret must be strong and at least 32 characters.
- `next.config.mjs` is configured with `output: 'standalone'` for slim Docker images.
