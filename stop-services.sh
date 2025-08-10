#!/bin/bash

# Microservices Stop Script
echo "🛑 Stopping Microservices CRUD Application"
echo "========================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to stop service
stop_service() {
    local service_name=$1
    
    if [ -f "logs/${service_name}.pid" ]; then
        local pid=$(cat logs/${service_name}.pid)
        if ps -p $pid > /dev/null; then
            echo -e "${YELLOW}Stopping $service_name (PID: $pid)...${NC}"
            kill $pid
            sleep 2
            if ps -p $pid > /dev/null; then
                echo -e "${RED}Force killing $service_name...${NC}"
                kill -9 $pid
            fi
            echo -e "${GREEN}$service_name stopped${NC}"
        else
            echo -e "${YELLOW}$service_name is not running${NC}"
        fi
        rm -f logs/${service_name}.pid
    else
        echo -e "${YELLOW}No PID file found for $service_name${NC}"
    fi
}

# Stop all services
stop_service "User Service"
stop_service "Product Service"
stop_service "Order Service"
stop_service "API Gateway"
stop_service "Eureka Server"

# Kill any remaining Java processes on our ports
echo -e "\n${YELLOW}Checking for remaining processes on service ports...${NC}"
PORTS=(8083 8081 8082 8080 8761)
for port in "${PORTS[@]}"; do
    pid=$(lsof -ti:$port)
    if [ ! -z "$pid" ]; then
        echo -e "${RED}Killing process on port $port (PID: $pid)${NC}"
        kill -9 $pid
    fi
done

echo -e "\n${GREEN}All services stopped successfully!${NC}"

