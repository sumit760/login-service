#!/bin/bash

# Microservices Startup Script
echo "🚀 Starting Microservices CRUD Application"
echo "=========================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to check if port is available
check_port() {
    if lsof -Pi :$1 -sTCP:LISTEN -t >/dev/null ; then
        echo -e "${RED}Port $1 is already in use${NC}"
        return 1
    else
        echo -e "${GREEN}Port $1 is available${NC}"
        return 0
    fi
}

# Function to start service
start_service() {
    local service_name=$1
    local service_dir=$2
    local port=$3
    
    echo -e "\n${BLUE}Starting $service_name on port $port...${NC}"
    
    if check_port $port; then
        cd $service_dir
        mvn spring-boot:run > ../logs/${service_name}.log 2>&1 &
        echo $! > ../logs/${service_name}.pid
        echo -e "${GREEN}$service_name started successfully${NC}"
        cd ..
    else
        echo -e "${RED}Failed to start $service_name - port $port is busy${NC}"
    fi
}

# Create logs directory
mkdir -p logs

echo -e "\n${YELLOW}Checking port availability...${NC}"

# Check all required ports
PORTS=(8083 8081 8082 8080 8761)
for port in "${PORTS[@]}"; do
    check_port $port
done

echo -e "\n${YELLOW}Starting services...${NC}"

# Start User Service (Enhanced Login Service)
start_service "User Service" "." 8083

# Wait a bit before starting next service
sleep 5

# Start Product Service
start_service "Product Service" "product-service" 8081

echo -e "\n${GREEN}Services are starting up...${NC}"
echo -e "\n${YELLOW}Service URLs:${NC}"
echo -e "User Service:    http://localhost:8083"
echo -e "  - Swagger UI:  http://localhost:8083/swagger-ui.html"
echo -e "  - H2 Console:  http://localhost:8083/h2-console"
echo -e "\nProduct Service: http://localhost:8081"
echo -e "  - Swagger UI:  http://localhost:8081/swagger-ui.html"
echo -e "  - H2 Console:  http://localhost:8081/h2-console"

echo -e "\n${YELLOW}Database Credentials:${NC}"
echo -e "URL: jdbc:h2:mem:userdb (User) / jdbc:h2:mem:productdb (Product)"
echo -e "Username: sa"
echo -e "Password: password"

echo -e "\n${YELLOW}To stop services, run:${NC} ./stop-services.sh"
echo -e "\n${GREEN}All services are starting up! Check logs/ directory for detailed logs.${NC}"

