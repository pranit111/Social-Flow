# Production Dockerfile for Postiz
# Multi-stage build to reduce memory usage and final image size

# Stage 1: Build stage
FROM node:22.20-bookworm AS builder

# Install build dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    g++ \
    make \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Install pnpm
RUN npm --no-update-notifier --no-fund --global install pnpm@10.6.1

WORKDIR /app

# Copy package files
COPY package.json pnpm-lock.yaml pnpm-workspace.yaml .npmrc ./
COPY apps/backend/package.json ./apps/backend/
COPY apps/frontend/package.json ./apps/frontend/
COPY apps/orchestrator/package.json ./apps/orchestrator/

# Install dependencies with production flag to reduce size
RUN pnpm install --frozen-lockfile --ignore-scripts

# Copy source code
COPY . .

# Build arguments
ARG NEXT_PUBLIC_VERSION
ENV NEXT_PUBLIC_VERSION=$NEXT_PUBLIC_VERSION

# Generate Prisma client
RUN pnpm run prisma-generate

# Build apps with reduced memory settings (suitable for 8GB VPS)
ENV NODE_OPTIONS="--max-old-space-size=3072"
RUN pnpm --filter ./apps/backend run build && \
    rm -rf /root/.cache /tmp/* || true

RUN pnpm --filter ./apps/orchestrator run build && \
    rm -rf /root/.cache /tmp/* || true

RUN pnpm --filter ./apps/frontend run build && \
    rm -rf /root/.cache /tmp/* || true

# Remove dev dependencies to save space
RUN pnpm install --prod --ignore-scripts

# Stage 2: Runtime stage
FROM node:22.20-bookworm-slim

# Install runtime dependencies including build tools for native modules
RUN apt-get update && apt-get install -y --no-install-recommends \
    bash \
    nginx \
    curl \
    python3 \
    make \
    g++ \
    && rm -rf /var/lib/apt/lists/*

# Setup nginx user and directories
RUN addgroup --system www \
    && adduser --system --ingroup www --home /www --shell /usr/sbin/nologin www \
    && mkdir -p /www /uploads \
    && chown -R www:www /www /var/lib/nginx /uploads

# Install pnpm and pm2
RUN npm --no-update-notifier --no-fund --global install pnpm@10.6.1 pm2

WORKDIR /app

# Copy built application from builder stage
COPY --from=builder /app /app

# Rebuild native modules for the runtime environment
RUN cd /app && pnpm rebuild bcrypt

# Copy nginx configuration
COPY var/docker/nginx.conf /etc/nginx/nginx.conf

# Create uploads directory with correct permissions
RUN mkdir -p /uploads && chmod 755 /uploads

# Expose port
EXPOSE 5000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:5000/api/health || exit 1

# Start nginx and applications with pm2
CMD ["sh", "-c", "nginx && pnpm run pm2"]
