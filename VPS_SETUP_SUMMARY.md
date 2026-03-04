# 🚀 Complete VPS Deployment Setup - Summary

This document provides a complete overview of your VPS deployment setup for Postiz.

## ✅ What Has Been Created

I've created **7 new files** to enable VPS hosting with CI/CD:

### Core Deployment Files

1. **`Dockerfile`** - Production Dockerfile
   - Builds all services (frontend, backend, orchestrator) from source
   - Uses multi-stage build for optimization
   - Includes nginx as reverse proxy
   - Uses PM2 for process management
   - Ready for your custom builds (not official Postiz registry)

2. **`docker-compose.prod.yaml`** - Production Docker Compose
   - Complete stack setup (app + PostgreSQL + Redis + Temporal)
   - Environment variable configuration
   - Volume management for persistent data
   - Health checks for all services
   - Network isolation

3. **`.github/workflows/deploy-to-vps.yml`** - GitHub Actions CI/CD
   - Automatic builds on push to main/master
   - Builds from YOUR source code
   - Transfers image to VPS via SSH
   - Automated deployment
   - Health checks after deployment
   - No dependency on Docker registry

### Configuration & Documentation

4. **`.env.production`** - Environment template
   - All configuration options
   - Secure defaults
   - Comprehensive comments
   - Social media integrations
   - Payment settings

5. **`VPS_DEPLOYMENT.md`** - Complete deployment guide (7 parts)
   - Part 1: VPS initial setup
   - Part 2: GitHub Actions configuration
   - Part 3: Initial deployment
   - Part 4: Verification & monitoring
   - Part 5: Maintenance & troubleshooting
   - Part 6: Security best practices
   - Part 7: Performance optimization

6. **`scripts/vps-quick-start.sh`** - Automated setup script
   - One-command VPS setup
   - Auto-generates secure credentials
   - Configures firewall
   - Deploys application

7. **`DEPLOYMENT_README.md`** - Quick reference guide
   - Overview of all files
   - Quick start instructions
   - Common commands
   - Troubleshooting guide

## 🎯 Three Deployment Options

### Option 1: Quick Start (Easiest)
```bash
# On your VPS
curl -o setup.sh https://raw.githubusercontent.com/YOUR_USERNAME/YOUR_REPO/main/scripts/vps-quick-start.sh
chmod +x setup.sh
./setup.sh
```

### Option 2: Manual Setup (Most Control)
Follow the complete guide in `VPS_DEPLOYMENT.md`

### Option 3: CI/CD (After Initial Setup)
1. Configure GitHub Secrets
2. Push to main branch
3. Automatic deployment

## 🔑 Key Features

### ✅ Builds from Source Code
- Uses **YOUR** code, not official Docker images
- Full control over what's deployed
- Custom modifications supported
- No dependency on ghcr.io/gitroomhq/postiz-app

### ✅ Automated CI/CD
- Push code → Automatic build → Deploy to VPS
- No manual Docker commands needed
- Health checks included
- Deployment notifications

### ✅ Complete Stack
- Frontend (Next.js) ✅
- Backend (NestJS) ✅
- Orchestrator (Temporal workflows) ✅
- PostgreSQL ✅
- Redis ✅
- Temporal ✅
- Nginx reverse proxy ✅

### ✅ Production Ready
- Health checks
- Persistent volumes
- Automatic restarts
- Logging
- Resource limits
- Security configurations

## 📋 Setup Steps

### Step 1: Prepare Your VPS
```bash
# Requirements:
- Ubuntu 20.04+ or Debian 11+
- 4GB+ RAM (8GB recommended)
- 20GB+ free disk space
- Docker 24.0+
- SSH access
```

### Step 2: Configure GitHub Repository

Add these secrets to GitHub (Settings → Secrets → Actions):

| Secret | Description | Example |
|--------|-------------|---------|
| `VPS_HOST` | VPS IP or domain | `123.45.67.89` |
| `VPS_USERNAME` | SSH username | `ubuntu` or `root` |
| `VPS_SSH_KEY` | Private SSH key | Contents of ~/.ssh/id_ed25519 |
| `VPS_PORT` | SSH port (optional) | `22` |

**Generate SSH key on VPS:**
```bash
ssh-keygen -t ed25519 -C "github-actions" -f ~/.ssh/github-actions -N ""
cat ~/.ssh/github-actions.pub >> ~/.ssh/authorized_keys
cat ~/.ssh/github-actions  # Copy this to GitHub Secret VPS_SSH_KEY
```

### Step 3: Create Environment File on VPS

```bash
# On VPS
mkdir -p /opt/postiz
cd /opt/postiz

# Create .env file
nano .env
```

Copy from `.env.production` and update:
- `MAIN_URL` - Your domain or VPS IP
- `JWT_SECRET` - Generate with: `openssl rand -base64 48`
- `POSTGRES_PASSWORD` - Strong database password
- Other settings as needed

### Step 4: Initial Deployment

**Option A: Use Quick Start Script**
```bash
# Run the automated script
./scripts/vps-quick-start.sh
```

**Option B: Manual First Deployment**
```bash
# Copy files to VPS
scp docker-compose.prod.yaml your-user@vps-ip:/opt/postiz/
scp -r dynamicconfig your-user@vps-ip:/opt/postiz/

# On VPS
cd /opt/postiz
docker compose -f docker-compose.prod.yaml up -d
```

**Option C: GitHub Actions (After secrets configured)**
```bash
# Just push to main
git add .
git commit -m "Setup deployment"
git push origin main
```

### Step 5: Access Your Application

- **Main App**: http://your-vps-ip:4007
- **Temporal UI**: http://your-vps-ip:8080

### Step 6: Setup SSL (Optional but Recommended)

```bash
# Install Certbot
sudo apt install nginx certbot python3-certbot-nginx -y

# Configure nginx (see VPS_DEPLOYMENT.md for config)
sudo nano /etc/nginx/sites-available/postiz

# Enable and get SSL
sudo ln -s /etc/nginx/sites-available/postiz /etc/nginx/sites-enabled/
sudo certbot --nginx -d your-domain.com
```

## 🔄 How CI/CD Works

```
1. Developer pushes code to GitHub (main branch)
   ↓
2. GitHub Actions triggers automatically
   ↓
3. Builds Docker image from YOUR source code
   ↓
4. Compresses image to tar.gz
   ↓
5. Transfers to VPS via SSH/SCP
   ↓
6. Loads new image on VPS
   ↓
7. Stops old containers
   ↓
8. Starts new containers
   ↓
9. Runs health checks
   ↓
10. Reports deployment status
```

## 🛠️ Daily Operations

### View Application Logs
```bash
cd /opt/postiz
docker compose -f docker-compose.prod.yaml logs -f postiz-app
```

### Restart Application
```bash
docker compose -f docker-compose.prod.yaml restart postiz-app
```

### Check Container Status
```bash
docker compose -f docker-compose.prod.yaml ps
```

### Update Application
Just push to main branch - CI/CD handles it!
```bash
git add .
git commit -m "Update feature"
git push origin main
```

### Backup Database
```bash
docker exec postiz-postgres pg_dump -U postiz-user postiz-db | gzip > backup-$(date +%Y%m%d).sql.gz
```

### Restore Database
```bash
gunzip < backup-20260302.sql.gz | docker exec -i postiz-postgres psql -U postiz-user postiz-db
```

## 🔒 Security Checklist

- [ ] Generate strong JWT_SECRET (not the default!)
- [ ] Change all database passwords
- [ ] Setup UFW firewall
- [ ] Configure SSL with Let's Encrypt
- [ ] Disable SSH password authentication (use keys only)
- [ ] Regular database backups (automated)
- [ ] Keep Docker and system updated
- [ ] Monitor logs for suspicious activity
- [ ] Use strong passwords for all services
- [ ] Limit SSH access to specific IPs (optional)

## 📊 Monitoring

### Check Service Health
```bash
# Check if services are healthy
docker compose -f docker-compose.prod.yaml ps

# Check individual service
docker inspect postiz-app --format='{{.State.Health.Status}}'
```

### Monitor Resource Usage
```bash
# Overall Docker stats
docker stats

# Disk usage
docker system df
df -h
```

### View All Logs
```bash
# All services
docker compose -f docker-compose.prod.yaml logs -f

# Specific service
docker compose -f docker-compose.prod.yaml logs -f postiz-app
docker compose -f docker-compose.prod.yaml logs -f postiz-postgres
```

## ❓ Common Questions

### Q: Will this use the official Postiz Docker image?
**A:** No! This setup builds from YOUR source code. You have full control.

### Q: Can I customize the code?
**A:** Yes! Any changes you push will be automatically built and deployed.

### Q: What if deployment fails?
**A:** The old version keeps running. Check GitHub Actions logs for errors.

### Q: How do I rollback?
**A:** Either:
1. Revert the commit and push
2. Manually deploy previous version on VPS

### Q: Can I use this without GitHub Actions?
**A:** Yes! You can build and deploy manually using Docker commands.

### Q: Do I need a domain name?
**A:** No, you can use VPS IP. But domain is recommended for SSL.

### Q: How much does it cost?
**A:** Only VPS costs (typically $5-20/month). GitHub Actions are free for public repos.

## 🆘 Troubleshooting

### Problem: Can't access application
```bash
# Check if containers are running
docker compose -f docker-compose.prod.yaml ps

# Check firewall
sudo ufw status

# Check logs
docker compose -f docker-compose.prod.yaml logs postiz-app
```

### Problem: Database connection error
```bash
# Check database is healthy
docker compose -f docker-compose.prod.yaml ps postiz-postgres

# Verify DATABASE_URL in .env
cat .env | grep DATABASE_URL

# Check database logs
docker compose -f docker-compose.prod.yaml logs postiz-postgres
```

### Problem: Out of disk space
```bash
# Clean Docker
docker system prune -a --volumes -f

# Check disk usage
df -h
docker system df
```

### Problem: GitHub Actions deployment fails
1. Check GitHub Actions logs in repository
2. Verify GitHub Secrets are correct
3. Check VPS disk space
4. Verify SSH access works manually
5. Check VPS logs: `docker compose logs`

## 📚 Documentation

- **Quick Reference**: `DEPLOYMENT_README.md`
- **Complete Guide**: `VPS_DEPLOYMENT.md` (7 Parts, very detailed)
- **Environment Config**: `.env.production`
- **Official Postiz Docs**: https://docs.postiz.com/

## 🎉 Success Criteria

Your deployment is successful when:
- ✅ All containers show "Up" and "healthy" status
- ✅ Application accessible at http://your-vps:4007
- ✅ No errors in logs
- ✅ Can create account and login
- ✅ GitHub Actions deployment completes successfully

## 📞 Next Steps

1. ✅ Commit these new files to your repository
2. ✅ Follow VPS setup in `VPS_DEPLOYMENT.md`
3. ✅ Configure GitHub Secrets
4. ✅ Deploy to VPS
5. ✅ Setup monitoring and backups
6. ✅ Configure SSL with domain (optional)
7. ✅ Add social media integrations

---

**🎯 Quick Start Command:**
```bash
# On your VPS - Run this to get started!
curl -o setup.sh https://raw.githubusercontent.com/YOUR_USERNAME/YOUR_REPO/main/scripts/vps-quick-start.sh
chmod +x setup.sh
./setup.sh
```

Replace `YOUR_USERNAME/YOUR_REPO` with your actual GitHub repository path.

Good luck with your deployment! 🚀
