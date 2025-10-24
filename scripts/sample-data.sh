#!/bin/bash

# Sample Data Initialization Script
echo "🌱 Initializing Sample Data for Microservices"
echo "============================================="

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Base URLs
USER_SERVICE_URL="http://localhost:8083/api/v1"
PRODUCT_SERVICE_URL="http://localhost:8081/api/v1"

echo -e "\n${YELLOW}Creating sample users...${NC}"

# Create sample users
curl -X POST $USER_SERVICE_URL/register \
  -H "Content-Type: application/json" \
  -d '{
    "username": "admin",
    "email": "admin@example.com",
    "password": "admin123",
    "firstName": "Admin",
    "lastName": "User",
    "phoneNumber": "+1234567890"
  }' && echo -e "\n${GREEN}✓ Admin user created${NC}"

curl -X POST $USER_SERVICE_URL/register \
  -H "Content-Type: application/json" \
  -d '{
    "username": "johndoe",
    "email": "john@example.com",
    "password": "password123",
    "firstName": "John",
    "lastName": "Doe",
    "phoneNumber": "+1234567891"
  }' && echo -e "${GREEN}✓ John Doe created${NC}"

curl -X POST $USER_SERVICE_URL/register \
  -H "Content-Type: application/json" \
  -d '{
    "username": "janedoe",
    "email": "jane@example.com",
    "password": "password123",
    "firstName": "Jane",
    "lastName": "Doe",
    "phoneNumber": "+1234567892"
  }' && echo -e "${GREEN}✓ Jane Doe created${NC}"

echo -e "\n${YELLOW}Creating sample products...${NC}"

# Create sample products
curl -X POST $PRODUCT_SERVICE_URL/products \
  -H "Content-Type: application/json" \
  -d '{
    "name": "MacBook Pro 16-inch",
    "description": "Apple MacBook Pro with M2 Pro chip, 16GB RAM, 512GB SSD",
    "price": 2499.99,
    "category": "Electronics",
    "sku": "MBP16-001",
    "stockQuantity": 25,
    "imageUrl": "https://example.com/macbook-pro.jpg",
    "weight": 2.1,
    "dimensions": "35.57 x 24.81 x 1.68 cm"
  }' && echo -e "\n${GREEN}✓ MacBook Pro created${NC}"

curl -X POST $PRODUCT_SERVICE_URL/products \
  -H "Content-Type: application/json" \
  -d '{
    "name": "iPhone 15 Pro",
    "description": "Latest iPhone with A17 Pro chip, 128GB storage",
    "price": 999.99,
    "category": "Electronics",
    "sku": "IPH15-001",
    "stockQuantity": 50,
    "imageUrl": "https://example.com/iphone-15.jpg",
    "weight": 0.187,
    "dimensions": "14.67 x 7.08 x 0.83 cm"
  }' && echo -e "${GREEN}✓ iPhone 15 Pro created${NC}"

curl -X POST $PRODUCT_SERVICE_URL/products \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Dell XPS 13",
    "description": "Ultra-thin laptop with Intel i7, 16GB RAM, 1TB SSD",
    "price": 1299.99,
    "category": "Electronics",
    "sku": "DELL-XPS13-001",
    "stockQuantity": 30,
    "imageUrl": "https://example.com/dell-xps13.jpg",
    "weight": 1.2,
    "dimensions": "29.6 x 19.9 x 1.48 cm"
  }' && echo -e "${GREEN}✓ Dell XPS 13 created${NC}"

curl -X POST $PRODUCT_SERVICE_URL/products \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Sony WH-1000XM5",
    "description": "Premium noise-canceling wireless headphones",
    "price": 399.99,
    "category": "Audio",
    "sku": "SONY-WH1000XM5",
    "stockQuantity": 75,
    "imageUrl": "https://example.com/sony-headphones.jpg",
    "weight": 0.25,
    "dimensions": "26.4 x 19.0 x 7.3 cm"
  }' && echo -e "${GREEN}✓ Sony Headphones created${NC}"

curl -X POST $PRODUCT_SERVICE_URL/products \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Samsung 4K Monitor",
    "description": "32-inch 4K UHD monitor with HDR support",
    "price": 549.99,
    "category": "Electronics",
    "sku": "SAM-MON32-001",
    "stockQuantity": 20,
    "imageUrl": "https://example.com/samsung-monitor.jpg",
    "weight": 7.2,
    "dimensions": "71.2 x 41.3 x 20.6 cm"
  }' && echo -e "${GREEN}✓ Samsung Monitor created${NC}"

curl -X POST $PRODUCT_SERVICE_URL/products \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Logitech MX Master 3",
    "description": "Advanced wireless mouse for productivity",
    "price": 99.99,
    "category": "Accessories",
    "sku": "LOG-MX3-001",
    "stockQuantity": 100,
    "imageUrl": "https://example.com/logitech-mouse.jpg",
    "weight": 0.141,
    "dimensions": "12.4 x 8.4 x 5.1 cm"
  }' && echo -e "${GREEN}✓ Logitech Mouse created${NC}"

echo -e "\n${BLUE}Sample data initialization completed!${NC}"
echo -e "\n${YELLOW}You can now test the APIs with the following sample data:${NC}"
echo -e "Users: admin, johndoe, janedoe (password: admin123/password123)"
echo -e "Products: MacBook Pro, iPhone 15 Pro, Dell XPS 13, Sony Headphones, Samsung Monitor, Logitech Mouse"

echo -e "\n${YELLOW}Test login with:${NC}"
echo -e "curl -X POST $USER_SERVICE_URL/login -H 'Content-Type: application/json' -d '{\"username\":\"admin\",\"password\":\"admin123\"}'"

