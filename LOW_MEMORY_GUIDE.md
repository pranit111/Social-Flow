# Low-Memory Optimization Guide for Postiz

## Overview
This guide provides optimized configurations for running Postiz on systems with limited memory (2-4GB RAM).

## What Was Optimized

### 1. **Removed Services**
- ❌ Elasticsearch (Temporal uses PostgreSQL instead)
- ❌ Temporal UI (Web interface)
- ❌ Temporal Admin Tools
- ❌ Spotlight monitoring
- ❌ Separate Temporal PostgreSQL (consolidated into single database)

### 2. **Memory Limits Applied**
| Service | Memory Limit | Reserved |
|---------|-------------|----------|
| Postiz (main app) | 768MB | 512MB |
| PostgreSQL | 256MB | 128MB |
| Redis | 150MB | 100MB |
| Temporal | 512MB | 256MB |
| **Total** | **~1.7GB** | **~1GB** |

### 3. **PostgreSQL Optimizations**
```
shared_buffers=128MB
effective_cache_size=256MB
maintenance_work_mem=64MB
work_mem=4MB
max_connections=100
```

### 4. **Redis Optimizations**
```
maxmemory 128mb
maxmemory-policy allkeys-lru
save "" (disabled persistence)
appendonly no
```

### 5. **Node.js Optimizations**
```
--max-old-space-size=512
--max-semi-space-size=2
--optimize-for-size
```

## Quick Start

### Option 1: Using Low-Memory Docker Compose
```bash
# Copy the low-memory compose file
cp docker-compose.low-memory.yaml docker-compose.override.yaml

# Or use it directly
docker compose -f docker-compose.low-memory.yaml up -d
```

### Option 2: Using Low-Memory Dockerfile
```bash
# Build with low-memory Dockerfile
docker build -f Dockerfile.low-memory -t postiz-low-memory .

# Then update docker-compose to use this image
```

### Option 3: Apply to Existing Setup
Update your `docker-compose.yaml` with memory limits from `docker-compose.low-memory.yaml`

## Complete Setup Instructions

### 1. Create .env file
```bash
cp .env.example .env
# Edit .env with your settings
```

### 2. Build and start services
```bash
# Using low-memory configuration
docker compose -f docker-compose.low-memory.yaml up -d

# Check status
docker compose -f docker-compose.low-memory.yaml ps

# View logs
docker compose -f docker-compose.low-memory.yaml logs -f
```

### 3. Initialize database
```bash
# Run migrations (first time only)
docker compose -f docker-compose.low-memory.yaml exec postiz pnpm run prisma-db-push
```

### 4. Monitor memory usage
```bash
# Check container memory usage
docker stats

# Expected output should show ~1.5-2GB total usage
```

## Trade-offs

### What You Lose:
1. **Temporal Search:** No Elasticsearch means no advanced search in Temporal workflows
2. **Temporal UI:** No web interface to monitor workflows (but they still work)
3. **Redis Persistence:** Redis data is not saved to disk (faster, but data lost on restart)
4. **Lower Concurrency:** Reduced PostgreSQL connections and memory limits

### What You Keep:
✅ All core posting functionality
✅ Social media integrations
✅ Calendar and scheduling
✅ Analytics
✅ Media library
✅ Team management
✅ Background job processing

## Further Optimizations

### If you still need to reduce memory:

#### 1. Use SQLite Instead of PostgreSQL (Advanced)
This requires code changes but can save ~200MB:
```bash
# In .env
DATABASE_URL=file:/config/postiz.db
```

#### 2. Run Without Temporal (Advanced)
If you don't need workflow orchestration, you can disable the orchestrator:
- Remove temporal service from docker-compose
- Disable orchestrator in the main app
- **Warning:** This breaks scheduled posts and background jobs

#### 3. Use External Services
- Use managed PostgreSQL (RDS, Supabase, etc.)
- Use managed Redis (Redis Cloud, Upstash, etc.)
- Only run the main Postiz container

#### 4. Enable Swap (Linux)
```bash
# Add 2GB swap on VPS
sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile

# Make permanent
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
```

## Troubleshooting

### Container keeps restarting / OOM (Out of Memory)
```bash
# Check logs
docker compose logs postiz

# Increase swap space
# Or reduce NODE_OPTIONS max-old-space-size further
```

### Slow performance
```bash
# Increase memory limits slightly (if you have RAM available)
# Edit deploy.resources.limits.memory in docker-compose

# Or add swap space (see above)
```

### Database connection errors
```bash
# PostgreSQL might need more connections
# In docker-compose.low-memory.yaml, update PostgreSQL command:
-c max_connections=50  # Reduce if needed
```

### Redis connection lost
```bash
# Redis might be evicting too aggressively
# In docker-compose.low-memory.yaml, update Redis command:
--maxmemory 256mb  # Increase if you have RAM
```

## Memory Monitoring

### Check current usage:
```bash
# All containers
docker stats --no-stream

# Specific container
docker stats postiz --no-stream
```

### Alert if memory exceeds threshold:
```bash
# Simple monitoring script
while true; do
  docker stats --no-stream --format "table {{.Name}}\t{{.MemUsage}}" | grep -E "postiz|postgres|redis|temporal"
  sleep 60
done
```

## Recommended System Requirements

### Minimum (Low-Memory Configuration):
- **RAM:** 2GB (with 1-2GB swap)
- **CPU:** 1 core
- **Disk:** 10GB
- **OS:** Linux (Ubuntu 22.04+, Debian 11+)

### Comfortable (Low-Memory Configuration):
- **RAM:** 4GB
- **CPU:** 2 cores
- **Disk:** 20GB
- **OS:** Linux (Ubuntu 22.04+, Debian 11+)

### For Standard Configuration (original docker-compose.yaml):
- **RAM:** 8GB+
- **CPU:** 4 cores
- **Disk:** 50GB

## Production Tips

1. **Use a VPS with at least 2GB RAM + 2GB swap**
2. **Monitor memory regularly** with `docker stats`
3. **Set up automatic restarts** for containers (already configured with `restart: always`)
4. **Use external storage** (S3, Cloudflare R2) instead of local uploads
5. **Regular cleanup:**
   ```bash
   # Clean up Docker
   docker system prune -af --volumes
   
   # Clean up old uploads (if using local storage)
   find /var/lib/docker/volumes/postiz-uploads/_data -mtime +30 -delete
   ```

## Support

If you encounter issues:
1. Check logs: `docker compose -f docker-compose.low-memory.yaml logs -f`
2. Verify memory: `docker stats`
3. Check GitHub issues: https://github.com/gitroomhq/postiz-app/issues
4. Join Discord: https://discord.gg/postiz

## Comparison: Standard vs Low-Memory

| Metric | Standard Setup | Low-Memory Setup |
|--------|---------------|------------------|
| Memory Usage | ~4-6GB | ~1.5-2GB |
| Services | 9 containers | 4 containers |
| Build Time | ~10-15 min | ~8-12 min |
| Startup Time | ~2-3 min | ~1-2 min |
| Features | All | Core only |
| Temporal UI | ✅ Yes | ❌ No |
| Elasticsearch | ✅ Yes | ❌ No |
| Monitoring | ✅ Spotlight | ❌ None |
| Redis Persistence | ✅ Yes | ❌ No |
| Min RAM Required | 8GB | 2GB + swap |

---

**Note:** While this configuration significantly reduces memory usage, it's designed for small-scale deployments. For production with many users, consider upgrading to the standard configuration or using managed services.
