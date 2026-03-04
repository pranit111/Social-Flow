# VPS Deployment Files - Quick Reference

This directory contains all the necessary files for deploying Postiz on your VPS with automated CI/CD.

## 📁 Files Created

### 1. `Dockerfile` (Production)
Production-ready Dockerfile that builds frontend, backend, and orchestrator from source code. Includes nginx as reverse proxy and pm2 for process management.

### 2. `docker-compose.prod.yaml`
Complete Docker Compose configuration for production deployment including:
- Postiz application (frontend + backend + orchestrator)
- PostgreSQL database
- Redis cache
- Temporal workflow engine with UI
- Elasticsearch for Temporal

### 3. `.github/workflows/deploy-to-vps.yml`
GitHub Actions workflow that automatically:
- Builds Docker image from source on every push to main/master
- Transfers image to your VPS
- Deploys updated containers
- Runs health checks
- Sends deployment notifications

### 4. `VPS_DEPLOYMENT.md`
Comprehensive deployment guide covering:
- VPS initial setup and requirements
- Docker installation
- Environment configuration
- GitHub Actions setup
- Deployment procedures
- Monitoring and troubleshooting
- Backup and restore procedures
- Security best practices

### 5. `.env.production`
Template for production environment variables with:
- All required settings
- Optional integrations (social media, payments, storage)
- Secure defaults
- Detailed comments

### 6. `scripts/vps-quick-start.sh`
Automated setup script that:
- Checks prerequisites (Docker, Docker Compose)
- Creates application directory
- Generates secure credentials
- Sets up firewall (optional)
- Deploys the application

## 🚀 Quick Start

### Option 1: Automated Setup (Recommended for first-time users)

1. SSH to your VPS
2. Download the quick start script:
   ```bash
   curl -o setup.sh https://raw.githubusercontent.com/your-username/your-repo/main/scripts/vps-quick-start.sh
   chmod +x setup.sh
   ./setup.sh
   ```

### Option 2: Manual Setup (Full control)

Follow the complete guide in `VPS_DEPLOYMENT.md`

### Option 3: CI/CD Deployment (After initial setup)

1. Configure GitHub Secrets (see VPS_DEPLOYMENT.md Part 2)
2. Push to main branch
3. GitHub Actions automatically deploys

## 🔐 GitHub Secrets Required

Set these in your GitHub repository → Settings → Secrets:

| Secret Name | Description |
|------------|-------------|
| `VPS_HOST` | Your VPS IP or domain |
| `VPS_USERNAME` | SSH username |
| `VPS_SSH_KEY` | Private SSH key for authentication |
| `VPS_PORT` | SSH port (optional, default: 22) |

## 📋 Prerequisites

- **VPS**: Ubuntu 20.04+ or Debian 11+ with min 4GB RAM
- **Docker**: Version 24.0+
- **Domain**: Optional but recommended for production
- **SSH Access**: Required for deployment

## 🔧 Configuration

1. Copy `.env.production` to `/opt/postiz/.env` on your VPS
2. Update the following required settings:
   - `MAIN_URL`: Your domain or VPS IP
   - `JWT_SECRET`: Generate with `openssl rand -base64 48`
   - `POSTGRES_PASSWORD`: Strong password for database
3. Configure optional integrations as needed

## 📊 Monitoring

Access your services:
- **Main App**: http://your-vps-ip:4007
- **Temporal UI**: http://your-vps-ip:8080
- **Logs**: `docker compose -f docker-compose.prod.yaml logs -f`

## 🔄 Deployment Workflow

```
Developer → Git Push → GitHub Actions → Build Image → Transfer to VPS → Deploy → Health Check
```

Every push to main/master branch triggers automatic deployment.

## 🛠️ Common Commands

```bash
# Navigate to app directory
cd /opt/postiz

# View status
docker compose -f docker-compose.prod.yaml ps

# View logs
docker compose -f docker-compose.prod.yaml logs -f

# Restart services
docker compose -f docker-compose.prod.yaml restart

# Stop services
docker compose -f docker-compose.prod.yaml down

# Start services
docker compose -f docker-compose.prod.yaml up -d

# Backup database
docker exec postiz-postgres pg_dump -U postiz-user postiz-db | gzip > backup.sql.gz
```

## 🔒 Security Checklist

- [ ] Changed default passwords in .env
- [ ] Generated strong JWT_SECRET
- [ ] Configured UFW firewall
- [ ] Set up SSL with Certbot (if using domain)
- [ ] Regular database backups configured
- [ ] SSH key authentication enabled
- [ ] Unnecessary ports closed
- [ ] .env file permissions set to 600

## 📚 Additional Resources

- **Complete Guide**: See `VPS_DEPLOYMENT.md`
- **Official Docs**: https://docs.postiz.com/
- **GitHub Issues**: https://github.com/gitroomhq/postiz-app/issues

## 🆘 Troubleshooting

### Container won't start
```bash
docker compose -f docker-compose.prod.yaml logs postiz-app
```
Check for missing environment variables or database connection issues.

### Can't access application
1. Check firewall: `sudo ufw status`
2. Verify containers: `docker compose -f docker-compose.prod.yaml ps`
3. Check logs: `docker compose -f docker-compose.prod.yaml logs`

### Out of disk space
```bash
docker system prune -a --volumes -f
```

For more troubleshooting, see VPS_DEPLOYMENT.md Part 5.

## 🎯 Next Steps

1. ✅ Review `VPS_DEPLOYMENT.md` for detailed instructions
2. ✅ Set up your VPS following Part 1
3. ✅ Configure GitHub Actions following Part 2
4. ✅ Deploy your application
5. ✅ Set up monitoring and backups

---

**Note**: Never commit `.env` files to Git. Add them to `.gitignore`.
