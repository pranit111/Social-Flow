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

# Copy source code (needed for prisma-generate)
COPY . .

# Configure pnpm for better network handling
RUN pnpm config set fetch-retries 5 && \
    pnpm config set fetch-retry-mintimeout 20000 && \
    pnpm config set fetch-retry-maxtimeout 120000 && \
    pnpm config set fetch-timeout 300000

# Install dependencies with production flag to reduce size
RUN pnpm install --frozen-lockfile --ignore-scripts

# Build arguments
ARG NEXT_PUBLIC_VERSION
ENV NEXT_PUBLIC_VERSION=$NEXT_PUBLIC_VERSION

# Generate Prisma client
RUN pnpm run prisma-generate

# Build bcrypt native binding in the builder stage (has network access)
RUN pnpm rebuild bcrypt

# Build apps with reduced memory settings (suitable for 8GB VPS)
ENV NODE_OPTIONS="--max-old-space-size=3072"
RUN pnpm --filter ./apps/backend run build && \
    rm -rf /root/.cache /tmp/* || true

RUN pnpm --filter ./apps/orchestrator run build && \
    rm -rf /root/.cache /tmp/* || true

RUN pnpm --filter ./apps/frontend run build && \
    rm -rf /root/.cache /tmp/* || true

# Clean up build caches but preserve node_modules and build artifacts
RUN find . -name "*.log" -type f -delete && \
    find . -name ".turbo" -type d -exec rm -rf {} + 2>/dev/null || true

# Stage 2: Runtime stage - Use same base image to avoid native module issues
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

# Copy package files first
COPY --from=builder /app/package.json /app/pnpm-lock.yaml /app/pnpm-workspace.yaml /app/.npmrc ./
COPY --from=builder /app/apps/backend/package.json ./apps/backend/
COPY --from=builder /app/apps/frontend/package.json ./apps/frontend/
COPY --from=builder /app/apps/orchestrator/package.json ./apps/orchestrator/

# Copy built apps with their build artifacts
COPY --from=builder /app/apps ./apps
COPY --from=builder /app/libraries ./libraries
COPY --from=builder /app/dynamicconfig ./dynamicconfig
COPY --from=builder /app/node_modules ./node_modules

# Copy nginx configuration
COPY var/docker/nginx.conf /etc/nginx/nginx.conf

# Copy startup script
COPY scripts/docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

# Create uploads directory with correct permissions
RUN mkdir -p /uploads && chmod 755 /uploads

# Expose port
EXPOSE 5000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:5000/api/health || exit 1

# Use startup script as entrypoint
ENTRYPOINT ["/docker-entrypoint.sh"]
