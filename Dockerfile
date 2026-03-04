# Production Dockerfile for Postiz
# Builds frontend, backend, and orchestrator from source

FROM node:22.20-bookworm-slim AS base

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    g++ \
    make \
    python3-pip \
    bash \
    nginx \
    && rm -rf /var/lib/apt/lists/*

# Setup nginx user and directories
RUN addgroup --system www \
    && adduser --system --ingroup www --home /www --shell /usr/sbin/nologin www \
    && mkdir -p /www /uploads \
    && chown -R www:www /www /var/lib/nginx /uploads

# Install pnpm and pm2 globally
RUN npm --no-update-notifier --no-fund --global install pnpm@10.6.1 pm2

WORKDIR /app

# Copy package files first for better caching
COPY package.json pnpm-lock.yaml pnpm-workspace.yaml ./
COPY apps/backend/package.json ./apps/backend/
COPY apps/frontend/package.json ./apps/frontend/
COPY apps/orchestrator/package.json ./apps/orchestrator/

# Install dependencies
RUN pnpm install --frozen-lockfile

# Copy application source code
COPY . .

# Copy nginx configuration
COPY var/docker/nginx.conf /etc/nginx/nginx.conf

# Build arguments
ARG NEXT_PUBLIC_VERSION
ENV NEXT_PUBLIC_VERSION=$NEXT_PUBLIC_VERSION

# Generate Prisma client
RUN pnpm run prisma-generate

# Build all applications
RUN NODE_OPTIONS="--max-old-space-size=4096" pnpm run build

# Create uploads directory with correct permissions
RUN mkdir -p /uploads && chmod 755 /uploads

# Expose port
EXPOSE 5000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:5000/api/health || exit 1

# Start nginx and applications with pm2
CMD ["sh", "-c", "nginx && pnpm run pm2"]
