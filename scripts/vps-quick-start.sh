#!/bin/bash

# Quick Start Script for VPS Deployment
# This script helps you quickly set up Postiz on your VPS

set -e

echo "========================================="
echo "Postiz VPS Deployment Quick Start"
echo "========================================="
echo ""

# Check if running as root
if [ "$EUID" -eq 0 ]; then 
    echo "⚠️  Please do not run this script as root"
    echo "Run it as a regular user with sudo privileges"
    exit 1
fi

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "📦 Docker is not installed. Installing Docker..."
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    sudo usermod -aG docker $USER
    rm get-docker.sh
    echo "✅ Docker installed successfully"
    echo "⚠️  Please log out and log back in for Docker group changes to take effect"
    echo "Then run this script again"
    exit 0
else
    echo "✅ Docker is already installed"
fi

# Check if docker compose is available
if ! docker compose version &> /dev/null; then
    echo "❌ Docker Compose V2 is not available"
    echo "Please install Docker Compose V2"
    exit 1
else
    echo "✅ Docker Compose V2 is available"
fi

# Create application directory
APP_DIR="/opt/postiz"
echo ""
echo "📁 Creating application directory at $APP_DIR..."
sudo mkdir -p $APP_DIR
sudo chown $USER:$USER $APP_DIR
cd $APP_DIR

# Check if .env exists
if [ ! -f .env ]; then
    echo ""
    echo "📝 Creating .env file..."
    
    # Get VPS IP or domain
    read -p "Enter your VPS IP or domain (e.g., 123.45.67.89 or yourdomain.com): " VPS_ADDRESS
    
    # Generate JWT secret
    JWT_SECRET=$(openssl rand -base64 48 | tr -d '\n')
    
    # Generate database password
    DB_PASSWORD=$(openssl rand -base64 24 | tr -d '\n' | tr -d '/' | tr -d '+')
    
    # Create .env file
    cat > .env << EOF
# Postiz Production Configuration
# Generated on $(date)

# === Required Settings
MAIN_URL=http://${VPS_ADDRESS}:4007
FRONTEND_URL=http://${VPS_ADDRESS}:4007
NEXT_PUBLIC_BACKEND_URL=http://${VPS_ADDRESS}:4007/api
JWT_SECRET=${JWT_SECRET}
DATABASE_URL=postgresql://postiz-user:${DB_PASSWORD}@postiz-postgres:5432/postiz-db
REDIS_URL=redis://postiz-redis:6379
BACKEND_INTERNAL_URL=http://localhost:3000
TEMPORAL_ADDRESS=temporal:7233
IS_GENERAL=true
DISABLE_REGISTRATION=false

# === Storage Settings
STORAGE_PROVIDER=local
UPLOAD_DIRECTORY=/uploads
NEXT_PUBLIC_UPLOAD_DIRECTORY=/uploads

# === Database Credentials
POSTGRES_PASSWORD=${DB_PASSWORD}
POSTGRES_USER=postiz-user
POSTGRES_DB=postiz-db
TEMPORAL_DB_PASSWORD=temporal
TEMPORAL_DB_USER=temporal

# === Ports
POSTIZ_PORT=4007
POSTGRES_PORT=5432
REDIS_PORT=6379
TEMPORAL_PORT=7233
TEMPORAL_UI_PORT=8080

# === Misc
NX_ADD_PLUGINS=false
API_LIMIT=30
EOF

    echo "✅ .env file created with auto-generated secrets"
    echo ""
    echo "⚠️  IMPORTANT: Your credentials have been saved to .env"
    echo "Backup this file in a secure location!"
else
    echo "✅ .env file already exists"
fi

# Setup firewall
echo ""
read -p "Do you want to configure UFW firewall? (y/n): " SETUP_FIREWALL
if [[ $SETUP_FIREWALL == "y" || $SETUP_FIREWALL == "Y" ]]; then
    echo "🔥 Configuring UFW firewall..."
    sudo ufw --force enable
    sudo ufw allow 22/tcp  # SSH
    sudo ufw allow 80/tcp  # HTTP
    sudo ufw allow 443/tcp # HTTPS
    sudo ufw allow 4007/tcp # Postiz
    echo "✅ Firewall configured"
fi

# Check if docker-compose.prod.yaml exists
if [ ! -f docker-compose.prod.yaml ]; then
    echo ""
    echo "❌ docker-compose.prod.yaml not found in $APP_DIR"
    echo "Please copy docker-compose.prod.yaml and dynamicconfig folder from your repository to $APP_DIR"
    exit 1
fi

# Pull and start services
echo ""
read -p "Do you want to start Postiz now? (y/n): " START_NOW
if [[ $START_NOW == "y" || $START_NOW == "Y" ]]; then
    echo "🚀 Pulling Docker images..."
    docker compose -f docker-compose.prod.yaml pull
    
    echo "🚀 Starting Postiz..."
    docker compose -f docker-compose.prod.yaml up -d
    
    echo ""
    echo "⏳ Waiting for services to start (30 seconds)..."
    sleep 30
    
    echo ""
    echo "📊 Container Status:"
    docker compose -f docker-compose.prod.yaml ps
    
    echo ""
    echo "📋 Recent Logs:"
    docker compose -f docker-compose.prod.yaml logs --tail 20
fi

echo ""
echo "========================================="
echo "✅ Setup Complete!"
echo "========================================="
echo ""
echo "Access your Postiz instance at:"
echo "  🌐 Main App: http://${VPS_ADDRESS:-your-ip}:4007"
echo "  📊 Temporal UI: http://${VPS_ADDRESS:-your-ip}:8080"
echo ""
echo "Useful commands:"
echo "  📊 View logs:        cd $APP_DIR && docker compose -f docker-compose.prod.yaml logs -f"
echo "  🔄 Restart:          cd $APP_DIR && docker compose -f docker-compose.prod.yaml restart"
echo "  🛑 Stop:             cd $APP_DIR && docker compose -f docker-compose.prod.yaml down"
echo "  🚀 Start:            cd $APP_DIR && docker compose -f docker-compose.prod.yaml up -d"
echo "  📊 Status:           cd $APP_DIR && docker compose -f docker-compose.prod.yaml ps"
echo "  💾 Backup DB:        docker exec postiz-postgres pg_dump -U postiz-user postiz-db | gzip > backup.sql.gz"
echo ""
echo "📖 For complete documentation, see VPS_DEPLOYMENT.md"
echo "========================================="
