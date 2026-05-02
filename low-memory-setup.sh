#!/bin/bash
# Quick setup script for low-memory Postiz deployment
# Run this on your VPS or local machine
#
# Usage: bash low-memory-setup.sh

set -e

echo "=========================================="
echo "Postiz Low-Memory Setup Script"
echo "=========================================="
echo ""

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed. Please install Docker first."
    echo "Visit: https://docs.docker.com/get-docker/"
    exit 1
fi

# Check if Docker Compose is available
if ! docker compose version &> /dev/null; then
    echo "❌ Docker Compose is not available. Please install Docker Compose."
    exit 1
fi

echo "✅ Docker and Docker Compose are installed"
echo ""

# Check available memory
if command -v free &> /dev/null; then
    TOTAL_MEM=$(free -m | awk '/^Mem:/{print $2}')
    echo "📊 Available RAM: ${TOTAL_MEM}MB"
    
    if [ "$TOTAL_MEM" -lt 2048 ]; then
        echo "⚠️  Warning: Less than 2GB RAM detected. Consider adding swap space."
        echo ""
        read -p "Would you like to create a 2GB swap file? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            echo "Creating swap file..."
            sudo fallocate -l 2G /swapfile || sudo dd if=/dev/zero of=/swapfile bs=1M count=2048
            sudo chmod 600 /swapfile
            sudo mkswap /swapfile
            sudo swapon /swapfile
            echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
            echo "✅ Swap file created and enabled"
        fi
    fi
fi
echo ""

# Create .env if it doesn't exist
if [ ! -f .env ]; then
    if [ -f .env.example ]; then
        echo "📝 Creating .env file from template..."
        cp .env.example .env
        
        # Generate random JWT secret
        JWT_SECRET=$(openssl rand -base64 32 | tr -d "=+/" | cut -c1-64)
        sed -i "s/JWT_SECRET=.*/JWT_SECRET=${JWT_SECRET}/" .env 2>/dev/null || \
        sed -i.bak "s/JWT_SECRET=.*/JWT_SECRET=${JWT_SECRET}/" .env
        
        echo "✅ .env file created"
        echo "⚠️  Please edit .env and configure your settings"
        echo ""
        read -p "Press Enter to edit .env now (or Ctrl+C to skip)..."
        ${EDITOR:-nano} .env
    else
        echo "❌ .env.example not found. Please create .env manually."
        exit 1
    fi
else
    echo "✅ .env file already exists"
fi
echo ""

# Ask which configuration to use
echo "Which configuration would you like to use?"
echo "1) Low-Memory (Recommended for 2-4GB RAM systems)"
echo "2) Standard (Requires 8GB+ RAM)"
echo ""
read -p "Enter choice (1 or 2): " -n 1 -r
echo

if [[ $REPLY == "1" ]]; then
    COMPOSE_FILE="docker-compose.low-memory.yaml"
    DOCKERFILE="Dockerfile.low-memory"
    echo "✅ Using low-memory configuration"
elif [[ $REPLY == "2" ]]; then
    COMPOSE_FILE="docker-compose.yaml"
    DOCKERFILE="Dockerfile"
    echo "✅ Using standard configuration"
else
    echo "❌ Invalid choice. Exiting."
    exit 1
fi
echo ""

# Check if compose file exists
if [ ! -f "$COMPOSE_FILE" ]; then
    echo "❌ $COMPOSE_FILE not found!"
    exit 1
fi

# Stop existing containers
echo "🛑 Stopping existing containers (if any)..."
docker compose -f "$COMPOSE_FILE" down 2>/dev/null || true
echo ""

# Build images
echo "🔨 Building Docker images..."
echo "This may take 8-15 minutes depending on your system..."
docker compose -f "$COMPOSE_FILE" build
echo "✅ Build complete"
echo ""

# Start services
echo "🚀 Starting services..."
docker compose -f "$COMPOSE_FILE" up -d
echo ""

# Wait for services to be ready
echo "⏳ Waiting for services to start (60 seconds)..."
sleep 60

# Check service health
echo "🔍 Checking service status..."
docker compose -f "$COMPOSE_FILE" ps
echo ""

# Show memory usage
echo "📊 Current memory usage:"
docker stats --no-stream --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.MemPerc}}"
echo ""

# Get the main URL
MAIN_URL=$(grep MAIN_URL .env | cut -d '=' -f2 | tr -d ' ')
if [ -z "$MAIN_URL" ]; then
    MAIN_URL="http://localhost:4007"
fi

echo "=========================================="
echo "✅ Postiz is running!"
echo "=========================================="
echo ""
echo "🌐 Access Postiz at: $MAIN_URL"
echo ""
echo "📝 Useful commands:"
echo "  View logs:     docker compose -f $COMPOSE_FILE logs -f"
echo "  Stop:          docker compose -f $COMPOSE_FILE down"
echo "  Restart:       docker compose -f $COMPOSE_FILE restart"
echo "  Update:        git pull && docker compose -f $COMPOSE_FILE up -d --build"
echo "  Memory stats:  docker stats"
echo ""
echo "📚 Documentation:"
echo "  Main docs:     https://docs.postiz.com/"
echo "  Low-memory:    cat LOW_MEMORY_GUIDE.md"
echo ""

# Check if accessible
echo "🔍 Testing connection..."
sleep 5
if curl -f -s -o /dev/null -w "%{http_code}" "$MAIN_URL" | grep -q "200\|301\|302"; then
    echo "✅ Postiz is accessible!"
else
    echo "⚠️  Could not connect to $MAIN_URL"
    echo "   This is normal if you're running on a VPS."
    echo "   Make sure to configure your firewall and domain."
fi

echo ""
echo "=========================================="
echo "Setup complete! Happy posting! 🎉"
echo "=========================================="
