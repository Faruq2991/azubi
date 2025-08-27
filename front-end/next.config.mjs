/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: true,
  output:  'standalone',
  async rewrites() {
    return [
      {
        source: '/api/:path*',
        destination: 'http://azubi-backend-service/api/:path*',
      },
    ]
  },
};

export default nextConfig;
