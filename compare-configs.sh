#!/bin/bash
# Postiz Configuration Comparison Tool
# Shows the difference between Standard and Low-Memory setups

echo "╔════════════════════════════════════════════════════════╗"
echo "║    Postiz: Standard vs Low-Memory Configuration        ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""

# Function to check if a service is defined in compose file
check_service() {
    local file=$1
    local service=$2
    if [ -f "$file" ]; then
        if grep -q "^  $service:" "$file"; then
            echo "✅"
        else
            echo "❌"
        fi
    else
        echo "⚠️"
    fi
}

# Function to get memory limit for a service
get_memory_limit() {
    local file=$1
    local service=$2
    if [ -f "$file" ]; then
        local mem=$(awk "/^  $service:/,/^  [a-z]/ {if(/memory: /) print \$2; if(/^  [a-z]/ && !/^  $service:/) exit}" "$file" | head -1)
        if [ -n "$mem" ]; then
            echo "$mem"
        else
            echo "unlimited"
        fi
    else
        echo "N/A"
    fi
}

echo "📋 Service Comparison:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
printf "%-30s %-15s %-15s\n" "Service" "Standard" "Low-Memory"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

STANDARD="docker-compose.yaml"
LOW_MEM="docker-compose.low-memory.yaml"

printf "%-30s %-15s %-15s\n" "Postiz (main app)" \
    "$(check_service $STANDARD postiz)" \
    "$(check_service $LOW_MEM postiz)"

printf "%-30s %-15s %-15s\n" "PostgreSQL" \
    "$(check_service $STANDARD postiz-postgres)" \
    "$(check_service $LOW_MEM postiz-postgres)"

printf "%-30s %-15s %-15s\n" "Redis" \
    "$(check_service $STANDARD postiz-redis)" \
    "$(check_service $LOW_MEM postiz-redis)"

printf "%-30s %-15s %-15s\n" "Elasticsearch" \
    "$(check_service $STANDARD temporal-elasticsearch)" \
    "$(check_service $LOW_MEM temporal-elasticsearch)"

printf "%-30s %-15s %-15s\n" "Temporal PostgreSQL" \
    "$(check_service $STANDARD temporal-postgresql)" \
    "$(check_service $LOW_MEM temporal-postgresql)"

printf "%-30s %-15s %-15s\n" "Temporal" \
    "$(check_service $STANDARD temporal)" \
    "$(check_service $LOW_MEM temporal)"

printf "%-30s %-15s %-15s\n" "Temporal UI" \
    "$(check_service $STANDARD temporal-ui)" \
    "$(check_service $LOW_MEM temporal-ui)"

printf "%-30s %-15s %-15s\n" "Temporal Admin Tools" \
    "$(check_service $STANDARD temporal-admin-tools)" \
    "$(check_service $LOW_MEM temporal-admin-tools)"

printf "%-30s %-15s %-15s\n" "Spotlight (monitoring)" \
    "$(check_service $STANDARD spotlight)" \
    "$(check_service $LOW_MEM spotlight)"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

echo "💾 Memory Limits:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
printf "%-30s %-15s %-15s\n" "Service" "Standard" "Low-Memory"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

printf "%-30s %-15s %-15s\n" "Postiz" \
    "$(get_memory_limit $STANDARD postiz)" \
    "$(get_memory_limit $LOW_MEM postiz)"

printf "%-30s %-15s %-15s\n" "PostgreSQL" \
    "$(get_memory_limit $STANDARD postiz-postgres)" \
    "$(get_memory_limit $LOW_MEM postiz-postgres)"

printf "%-30s %-15s %-15s\n" "Redis" \
    "$(get_memory_limit $STANDARD postiz-redis)" \
    "$(get_memory_limit $LOW_MEM postiz-redis)"

printf "%-30s %-15s %-15s\n" "Temporal" \
    "$(get_memory_limit $STANDARD temporal)" \
    "$(get_memory_limit $LOW_MEM temporal)"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

echo "📊 Estimated Total Memory Usage:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Standard Setup:       ~4-6 GB"
echo "Low-Memory Setup:     ~1.5-2 GB"
echo "Savings:              ~70% (3-4 GB less)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

echo "📦 Container Count:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if [ -f "$STANDARD" ]; then
    STANDARD_COUNT=$(grep -c "^  [a-z-]*:" "$STANDARD" || echo "0")
    echo "Standard Setup:       $STANDARD_COUNT containers"
fi
if [ -f "$LOW_MEM" ]; then
    LOW_MEM_COUNT=$(grep -c "^  [a-z-]*:" "$LOW_MEM" || echo "0")
    echo "Low-Memory Setup:     $LOW_MEM_COUNT containers"
fi
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

echo "✨ Feature Comparison:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
printf "%-45s %-10s %-10s\n" "Feature" "Standard" "Low-Mem"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
printf "%-45s %-10s %-10s\n" "Post to social media" "✅" "✅"
printf "%-45s %-10s %-10s\n" "Schedule posts" "✅" "✅"
printf "%-45s %-10s %-10s\n" "Calendar view" "✅" "✅"
printf "%-45s %-10s %-10s\n" "Analytics" "✅" "✅"
printf "%-45s %-10s %-10s\n" "Media library" "✅" "✅"
printf "%-45s %-10s %-10s\n" "Team management" "✅" "✅"
printf "%-45s %-10s %-10s\n" "Background jobs (Temporal)" "✅" "✅"
printf "%-45s %-10s %-10s\n" "Temporal Web UI" "✅" "❌"
printf "%-45s %-10s %-10s\n" "Temporal advanced search" "✅" "❌"
printf "%-45s %-10s %-10s\n" "Spotlight monitoring" "✅" "❌"
printf "%-45s %-10s %-10s\n" "Redis persistence" "✅" "❌"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

echo "💰 Estimated VPS Costs (monthly):"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Standard (8GB RAM):   $40-60/month"
echo "Low-Memory (4GB):     $20-30/month"
echo "Low-Memory (2GB):     $10-15/month"
echo "Savings:              ~60-75%"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

echo "🎯 Recommendation:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Check system memory
if command -v free &> /dev/null; then
    TOTAL_MEM=$(free -m | awk '/^Mem:/{print $2}')
    echo "Your system has: ${TOTAL_MEM}MB RAM"
    echo ""
    
    if [ "$TOTAL_MEM" -lt 3072 ]; then
        echo "✅ Use LOW-MEMORY configuration"
        echo "   Your system has limited RAM (<3GB)"
        echo "   Command: docker compose -f docker-compose.low-memory.yaml up -d"
        echo "   Consider adding 1-2GB swap space"
    elif [ "$TOTAL_MEM" -lt 6144 ]; then
        echo "⚠️  Use LOW-MEMORY configuration (recommended)"
        echo "   Your system has moderate RAM (3-6GB)"
        echo "   Command: docker compose -f docker-compose.low-memory.yaml up -d"
    else
        echo "✅ Use STANDARD configuration"
        echo "   Your system has sufficient RAM (>6GB)"
        echo "   Command: docker compose -f docker-compose.yaml up -d"
        echo "   Or use low-memory to save resources"
    fi
else
    echo "Use LOW-MEMORY if you have:"
    echo "  • Less than 4GB RAM"
    echo "  • A small VPS (2-4GB)"
    echo "  • Want to minimize costs"
    echo ""
    echo "Use STANDARD if you have:"
    echo "  • 8GB+ RAM"
    echo "  • Need Temporal UI"
    echo "  • Running many concurrent users"
fi
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

echo "📚 Next Steps:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "1. Read full guide:   cat LOW_MEMORY_GUIDE.md"
echo "2. Quick summary:     cat LOW_MEMORY_SUMMARY.md"
echo "3. Auto setup:        ./low-memory-setup.sh"
echo "4. Manual setup:      docker compose -f <config-file> up -d"
echo "5. Monitor:           docker stats"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
