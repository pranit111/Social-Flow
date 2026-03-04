# VPS Deployment Guide for Postiz

This guide will help you deploy Postiz on your VPS with automated CI/CD using GitHub Actions.

## 📋 Prerequisites

### VPS Requirements
- **OS**: Ubuntu 20.04+ or Debian 11+ (recommended)
- **RAM**: Minimum 4GB (8GB+ recommended)
- **Storage**: Minimum 20GB free space
- **CPU**: 2+ cores recommended
- **Docker**: Version 24.0+ with Docker Compose V2

### Local Requirements
- Git
- SSH access to your VPS
- GitHub repository access

## 🚀 Part 1: VPS Initial Setup

### 1.1 Install Docker on VPS

SSH into your VPS and run:

```bash
# Update system packages
sudo apt-get update
sudo apt-get upgrade -y

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Add your user to docker group (replace 'your-user' with your username)
sudo usermod -aG docker $USER

# Start and enable Docker
sudo systemctl start docker
sudo systemctl enable docker

# Log out and log back in for group changes to take effect
exit
```

Log back in and verify Docker installation:

```bash
docker --version
docker compose version
```

### 1.2 Create Application Directory

```bash
# Create directory for the application
sudo mkdir -p /opt/postiz
sudo chown $USER:$USER /opt/postiz
cd /opt/postiz
```

### 1.3 Create Environment Configuration

Create a `.env` file in `/opt/postiz`:

```bash
nano /opt/postiz/.env
```

Add your configuration (example):

```env
# === Required Settings
MAIN_URL=https://your-domain.com
FRONTEND_URL=https://your-domain.com
NEXT_PUBLIC_BACKEND_URL=https://your-domain.com/api
JWT_SECRET=your-super-secret-jwt-key-change-this-to-something-random-and-long
DATABASE_URL=postgresql://postiz-user:your-strong-password@postiz-postgres:5432/postiz-db
REDIS_URL=redis://postiz-redis:6379
BACKEND_INTERNAL_URL=http://localhost:3000
TEMPORAL_ADDRESS=temporal:7233
IS_GENERAL=true
DISABLE_REGISTRATION=false

# === Storage Settings (use local for simplicity)
STORAGE_PROVIDER=local
UPLOAD_DIRECTORY=/uploads
NEXT_PUBLIC_UPLOAD_DIRECTORY=/uploads

# === Database Settings
POSTGRES_PASSWORD=your-strong-password
POSTGRES_USER=postiz-user
POSTGRES_DB=postiz-db

# === Temporal Database
TEMPORAL_DB_PASSWORD=temporal
TEMPORAL_DB_USER=temporal

# === Ports (optional, defaults shown)
POSTIZ_PORT=4007
POSTGRES_PORT=5432
REDIS_PORT=6379
TEMPORAL_PORT=7233
TEMPORAL_UI_PORT=8080

# === Social Media API Settings (optional, configure as needed)
# X_API_KEY=
# X_API_SECRET=
# LINKEDIN_CLIENT_ID=
# LINKEDIN_CLIENT_SECRET=
# ... add others as needed

# === Cloudflare R2 Storage (optional alternative to local storage)
# STORAGE_PROVIDER=cloudflare
# CLOUDFLARE_ACCOUNT_ID=
# CLOUDFLARE_ACCESS_KEY=
# CLOUDFLARE_SECRET_ACCESS_KEY=
# CLOUDFLARE_BUCKETNAME=
# CLOUDFLARE_BUCKET_URL=
# CLOUDFLARE_REGION=auto

# === Payment Settings (optional)
# STRIPE_PUBLISHABLE_KEY=
# STRIPE_SECRET_KEY=
# STRIPE_SIGNING_KEY=
```

**Important**: 
- Replace `your-domain.com` with your actual domain
- Change all passwords to strong, unique values
- Generate a strong JWT_SECRET (minimum 32 characters)

### 1.4 Setup Firewall (UFW)

```bash
# Enable UFW
sudo ufw enable

# Allow SSH (important - don't lock yourself out!)
sudo ufw allow 22/tcp

# Allow HTTP and HTTPS
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp

# Allow Postiz port (if accessing directly)
sudo ufw allow 4007/tcp

# Check status
sudo ufw status
```

### 1.5 Setup Reverse Proxy with Nginx (Optional but Recommended)

For production, set up Nginx as a reverse proxy with SSL:

```bash
# Install Nginx
sudo apt-get install nginx certbot python3-certbot-nginx -y

# Create Nginx configuration
sudo nano /etc/nginx/sites-available/postiz
```

Add this configuration:

```nginx
server {
    listen 80;
    server_name your-domain.com;
    client_max_body_size 100M;

    location / {
        proxy_pass http://localhost:4007;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }
}
```

Enable the site and get SSL certificate:

```bash
# Enable the site
sudo ln -s /etc/nginx/sites-available/postiz /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx

# Get SSL certificate (replace your-domain.com and your-email@example.com)
sudo certbot --nginx -d your-domain.com --email your-email@example.com --agree-tos
```

## 🔧 Part 2: GitHub Actions Setup

### 2.1 Configure GitHub Secrets

Go to your GitHub repository → Settings → Secrets and variables → Actions → New repository secret

Add the following secrets:

| Secret Name | Description | Example |
|------------|-------------|---------|
| `VPS_HOST` | Your VPS IP address or domain | `123.45.67.89` |
| `VPS_USERNAME` | SSH username | `root` or `ubuntu` |
| `VPS_SSH_KEY` | Private SSH key for authentication | Your private SSH key content |
| `VPS_PORT` | SSH port (optional, default 22) | `22` |

### 2.2 Generate SSH Key for GitHub Actions

On your VPS:

```bash
# Generate new SSH key (without passphrase)
ssh-keygen -t ed25519 -C "github-actions" -f ~/.ssh/github-actions -N ""

# Add public key to authorized_keys
cat ~/.ssh/github-actions.pub >> ~/.ssh/authorized_keys

# Display private key (copy this to GitHub Secret VPS_SSH_KEY)
cat ~/.ssh/github-actions
```

Copy the entire private key output (including `-----BEGIN OPENSSH PRIVATE KEY-----` and `-----END OPENSSH PRIVATE KEY-----`) and add it to GitHub Secrets as `VPS_SSH_KEY`.

### 2.3 Test SSH Connection

From your local machine, test the connection:

```bash
ssh -i path/to/private-key username@vps-host
```

## 📦 Part 3: Initial Deployment

### 3.1 Manual First Deployment (Recommended)

For the first deployment, it's recommended to deploy manually to ensure everything works:

```bash
# On your local machine, clone the repository
git clone https://github.com/your-username/your-postiz-repo.git
cd your-postiz-repo

# Build the Docker image
docker build -f Dockerfile -t postiz-app:latest .

# Save the image
docker save postiz-app:latest | gzip > postiz-app-latest.tar.gz

# Copy to VPS
scp postiz-app-latest.tar.gz docker-compose.prod.yaml your-user@your-vps:/opt/postiz/
scp -r dynamicconfig your-user@your-vps:/opt/postiz/

# SSH to VPS
ssh your-user@your-vps

# Load and start
cd /opt/postiz
docker load -i postiz-app-latest.tar.gz
docker compose -f docker-compose.prod.yaml up -d

# Check logs
docker compose -f docker-compose.prod.yaml logs -f postiz-app
```

### 3.2 Automated Deployment via GitHub Actions

Once manual deployment works, push to your main/master branch:

```bash
git add .
git commit -m "Setup CI/CD deployment"
git push origin main
```

The GitHub Action will automatically:
1. Build the Docker image from source code
2. Transfer it to your VPS
3. Deploy the updated containers
4. Run health checks

Monitor the deployment in GitHub Actions tab of your repository.

## 🔍 Part 4: Verification & Monitoring

### 4.1 Check Container Status

```bash
cd /opt/postiz
docker compose -f docker-compose.prod.yaml ps
```

All containers should show "Up" and "healthy" status.

### 4.2 View Logs

```bash
# All services
docker compose -f docker-compose.prod.yaml logs -f

# Specific service
docker compose -f docker-compose.prod.yaml logs -f postiz-app
docker compose -f docker-compose.prod.yaml logs -f postiz-postgres
docker compose -f docker-compose.prod.yaml logs -f temporal
```

### 4.3 Access Your Application

- **Main Application**: https://your-domain.com (or http://your-vps-ip:4007)
- **Temporal UI**: http://your-vps-ip:8080

### 4.4 Database Access

To run Prisma migrations or access the database:

```bash
# Access PostgreSQL
docker exec -it postiz-postgres psql -U postiz-user -d postiz-db

# Run Prisma commands
docker exec -it postiz-app pnpm run prisma-db-push
```

## 🛠️ Part 5: Maintenance & Troubleshooting

### 5.1 Update Application

Simply push to your main branch, and GitHub Actions will handle deployment:

```bash
git add .
git commit -m "Your changes"
git push origin main
```

### 5.2 Manual Update (if needed)

```bash
cd /opt/postiz
docker compose -f docker-compose.prod.yaml pull
docker compose -f docker-compose.prod.yaml up -d
```

### 5.3 Restart Services

```bash
# Restart all
docker compose -f docker-compose.prod.yaml restart

# Restart specific service
docker compose -f docker-compose.prod.yaml restart postiz-app
```

### 5.4 Backup Database

```bash
# Create backup directory
mkdir -p /opt/postiz/backups

# Backup PostgreSQL
docker exec postiz-postgres pg_dump -U postiz-user postiz-db | gzip > /opt/postiz/backups/postiz-db-$(date +%Y%m%d-%H%M%S).sql.gz

# Automatic daily backups (add to crontab)
crontab -e
# Add this line:
# 0 2 * * * docker exec postiz-postgres pg_dump -U postiz-user postiz-db | gzip > /opt/postiz/backups/postiz-db-$(date +\%Y\%m\%d).sql.gz
```

### 5.5 Restore Database

```bash
# Stop application
docker compose -f docker-compose.prod.yaml stop postiz-app

# Restore database
gunzip < /opt/postiz/backups/your-backup.sql.gz | docker exec -i postiz-postgres psql -U postiz-user postiz-db

# Start application
docker compose -f docker-compose.prod.yaml start postiz-app
```

### 5.6 Common Issues

#### Issue: Container keeps restarting

```bash
# Check logs
docker logs postiz-app --tail 100

# Common causes:
# - Database connection failed: Check DATABASE_URL in .env
# - Redis connection failed: Check REDIS_URL in .env
# - Missing JWT_SECRET: Add to .env
```

#### Issue: Cannot access application

```bash
# Check if containers are running
docker compose -f docker-compose.prod.yaml ps

# Check if port is open
sudo netstat -tlnp | grep 4007

# Check firewall
sudo ufw status

# Check nginx (if using)
sudo nginx -t
sudo systemctl status nginx
```

#### Issue: Out of disk space

```bash
# Clean up Docker
docker system prune -a --volumes -f

# Check disk usage
df -h
docker system df
```

## 🔒 Part 6: Security Best Practices

1. **Use Strong Passwords**: Change all default passwords in `.env`
2. **Enable Firewall**: Only allow necessary ports
3. **Setup SSL**: Use Certbot for free SSL certificates
4. **Regular Updates**: Keep Docker and system packages updated
5. **Backup Regularly**: Automate database backups
6. **Monitor Logs**: Check logs regularly for suspicious activity
7. **Limit SSH Access**: Use SSH keys, disable password authentication
8. **Use Secrets**: Never commit `.env` files to Git

## 📊 Part 7: Performance Optimization

### 7.1 Increase Docker Resources

If you have enough RAM, edit docker-compose.prod.yaml:

```yaml
services:
  postiz:
    deploy:
      resources:
        limits:
          cpus: '2'
          memory: 4G
        reservations:
          memory: 2G
```

### 7.2 Enable Docker Logging Limits

Prevent log files from growing too large:

```yaml
services:
  postiz:
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"
```

### 7.3 Setup Monitoring

Consider installing monitoring tools:
- Portainer (Docker management)
- Prometheus + Grafana (metrics)
- Uptime Kuma (uptime monitoring)

## 📞 Support

- Documentation: https://docs.postiz.com/
- GitHub Issues: https://github.com/gitroomhq/postiz-app/issues
- Discord: Check the main README for Discord link

## 🎉 Congratulations!

Your Postiz instance should now be running on your VPS with automated CI/CD deployment. Every time you push to your main branch, GitHub Actions will automatically build and deploy your changes.
