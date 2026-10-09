/** @type {import('next').NextConfig} */
const nextConfig = {
  serverExternalPackages: ['@x402/core', '@x402/evm', '@x402/svm', '@coinbase/cdp-sdk'],
  turbopack: {}, // Satisfies Next.js Turbopack check
  webpack: (config) => {
    config.resolve.fallback = {
      ...config.resolve.fallback,
      fs: false,
      net: false,
      tls: false,
      '@x402/core': false,
      '@x402/evm': false,
      '@x402/svm': false,
    };
    return config;
  },
};

export default nextConfig;