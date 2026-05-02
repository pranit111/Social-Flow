# 🚀 Quick Reference: Low-Memory Postiz

## 📊 Memory Usage
- **Before:** 4-6 GB
- **After:** 1.5-2 GB (70% reduction!)

---

## 🏃 Quick Start Commands

### Linux/macOS (Automated)
```bash
chmod +x low-memory-setup.sh
./low-memory-setup.sh
```

### Linux/macOS (Manual)
```bash
cp .env.example .env
# Edit .env with your settings
docker compose -f docker-compose.low-memory.yaml up -d
```

### Windows (PowerShell)
```powershell
Copy-Item .env.example .env
# Edit .env with your settings
docker compose -f docker-compose.low-memory.yaml up -d
```

---

## 📁 Important Files

| File | Purpose |
|------|---------|
| `LOW_MEMORY_SUMMARY.md` | ⭐ Start here! Overview of everything |
| `LOW_MEMORY_GUIDE.md` | 📖 Complete documentation (200+ lines) |
| `docker-compose.low-memory.yaml` | 🐳 Low-memory configuration |
| `Dockerfile.low-memory` | 🔧 Optimized build file |
| `low-memory-setup.sh` | 🤖 Automated setup (Linux/macOS) |
| `compare-configs.sh` | 📊 Compare standard vs low-memory |

---

## 🎯 Top Commands

```bash
# Start services
docker compose -f docker-compose.low-memory.yaml up -d

# Check status
docker compose -f docker-compose.low-memory.yaml ps

# View logs
docker compose -f docker-compose.low-memory.yaml logs -f

# Check memory usage
docker stats

# Stop services
docker compose -f docker-compose.low-memory.yaml down

# Restart services
docker compose -f docker-compose.low-memory.yaml restart

# Rebuild and restart
docker compose -f docker-compose.low-memory.yaml up -d --build
```

---

## 💾 System Requirements

### Minimum
- 2GB RAM + 1-2GB swap
- 1 CPU core
- 10GB disk

### Recommended
- 4GB RAM
- 2 CPU cores
- 20GB disk

---

## ⚡ Add Swap (Linux)
```bash
sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
```

---

## ✅ What's Included

- ✅ All posting features
- ✅ Scheduling & calendar
- ✅ Analytics
- ✅ Media library
- ✅ Team management
- ✅ All integrations

## ❌ What's Removed

- ❌ Temporal UI
- ❌ Elasticsearch
- ❌ Spotlight monitoring
- ❌ Redis persistence

---

## 📚 Learn More

```bash
# Read summary (recommended first)
cat LOW_MEMORY_SUMMARY.md

# Read full guide
cat LOW_MEMORY_GUIDE.md

# Compare configurations
./compare-configs.sh
```

---

## 🆘 Quick Troubleshooting

### Container keeps restarting
```bash
# Check logs
docker compose -f docker-compose.low-memory.yaml logs postiz

# Add swap space (see above)
```

### Out of memory
```bash
# Add swap space
# Or increase limits in docker-compose.low-memory.yaml
```

### Slow performance
```bash
# Check current usage
docker stats

# Consider adding more RAM or swap
```

---

## 🌐 Access Your App

Default: http://localhost:4007

(Or use your configured MAIN_URL from .env)

---

## 💡 Pro Tips

1. Always use swap on systems with <4GB RAM
2. Monitor with `docker stats` regularly
3. Use external storage (S3, R2) for uploads
4. Backup PostgreSQL volumes regularly
5. Consider managed services for production

---

## 📞 Support

- **Docs:** https://docs.postiz.com/
- **Issues:** https://github.com/gitroomhq/postiz-app/issues
- **Discord:** https://discord.gg/postiz

---

**Need more details? Read [LOW_MEMORY_SUMMARY.md](LOW_MEMORY_SUMMARY.md)** 📖
