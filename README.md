# Microservice-Based CRUD Application

A comprehensive microservice architecture demonstration with Spring Boot, featuring user management, product catalog, order processing, and service discovery.

## 🏗️ Architecture Overview

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   API Gateway   │    │  Eureka Server  │    │   User Service  │
│   Port: 8080    │    │   Port: 8761    │    │   Port: 8083    │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                        │                        │
         └────────────────────────┼────────────────────────┘
                                  │
         ┌────────────────────────┼────────────────────────┐
         │                        │                        │
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│ Product Service │    │  Order Service  │    │   Databases     │
│   Port: 8081    │    │   Port: 8082    │    │   (H2 In-Mem)   │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## 🚀 Services

### 1. User Service (Enhanced Login Service)
- **Port**: 8083
- **Features**: User authentication, JWT tokens, full CRUD operations
- **Endpoints**:
  - `POST /api/v1/login` - User authentication
  - `POST /api/v1/register` - User registration
  - `GET /api/v1/users` - Get all users
  - `GET /api/v1/users/{id}` - Get user by ID
  - `PUT /api/v1/users/{id}` - Update user
  - `DELETE /api/v1/users/{id}` - Delete user
  - `GET /api/v1/users/active` - Get active users
  - `GET /api/v1/users/search?name={name}` - Search users

### 2. Product Service
- **Port**: 8081
- **Features**: Product catalog management, inventory tracking
- **Endpoints**:
  - `GET /api/v1/products` - Get all products
  - `POST /api/v1/products` - Create product
  - `GET /api/v1/products/{id}` - Get product by ID
  - `PUT /api/v1/products/{id}` - Update product
  - `DELETE /api/v1/products/{id}` - Delete product
  - `GET /api/v1/products/category/{category}` - Get by category
  - `GET /api/v1/products/search?name={name}` - Search products
  - `GET /api/v1/products/available` - Get available products
  - `PATCH /api/v1/products/{id}/stock?quantity={qty}` - Update stock

### 3. Order Service (Coming Soon)
- **Port**: 8082
- **Features**: Order management, inter-service communication

### 4. API Gateway (Coming Soon)
- **Port**: 8080
- **Features**: Single entry point, routing, load balancing

### 5. Eureka Server (Coming Soon)
- **Port**: 8761
- **Features**: Service discovery and registration

## 🛠️ Technology Stack

- **Framework**: Spring Boot 3.2.0
- **Language**: Java 17
- **Database**: H2 (In-Memory)
- **ORM**: Spring Data JPA / Hibernate
- **Security**: Spring Security + JWT
- **Documentation**: OpenAPI 3 / Swagger UI
- **Service Discovery**: Netflix Eureka
- **API Gateway**: Spring Cloud Gateway
- **Build Tool**: Maven
- **Containerization**: Docker & Docker Compose

## 🚦 Getting Started

### Prerequisites
- Java 17+
- Maven 3.6+
- Docker (optional)

### Running Individual Services

#### 1. User Service
```bash
cd login-service
mvn spring-boot:run
```
- Access: http://localhost:8083
- Swagger UI: http://localhost:8083/swagger-ui.html
- H2 Console: http://localhost:8083/h2-console

#### 2. Product Service
```bash
cd product-service
mvn spring-boot:run
```
- Access: http://localhost:8081
- Swagger UI: http://localhost:8081/swagger-ui.html
- H2 Console: http://localhost:8081/h2-console

### Database Configuration
- **URL**: `jdbc:h2:mem:userdb` (User Service) / `jdbc:h2:mem:productdb` (Product Service)
- **Username**: `sa`
- **Password**: `password`

## 📝 API Examples

### User Service Examples

#### Register a New User
```bash
curl -X POST http://localhost:8083/api/v1/register \
  -H "Content-Type: application/json" \
  -d '{
    "username": "johndoe",
    "email": "john@example.com",
    "password": "password123",
    "firstName": "John",
    "lastName": "Doe",
    "phoneNumber": "+1234567890"
  }'
```

#### Login
```bash
curl -X POST http://localhost:8083/api/v1/login \
  -H "Content-Type: application/json" \
  -d '{
    "username": "johndoe",
    "password": "password123"
  }'
```

#### Get All Users
```bash
curl -X GET http://localhost:8083/api/v1/users
```

### Product Service Examples

#### Create a Product
```bash
curl -X POST http://localhost:8081/api/v1/products \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Laptop",
    "description": "High-performance laptop",
    "price": 999.99,
    "category": "Electronics",
    "sku": "LAP001",
    "stockQuantity": 50
  }'
```

#### Get All Products
```bash
curl -X GET http://localhost:8081/api/v1/products
```

#### Search Products
```bash
curl -X GET "http://localhost:8081/api/v1/products/search?name=laptop"
```

## 🔧 Configuration

### Application Properties
Each service has its own `application.yml` with:
- Server port configuration
- Database settings
- Eureka client configuration
- JWT settings (User Service)
- Logging configuration

### Security Configuration
- JWT-based authentication for User Service
- Stateless session management
- CORS enabled for development
- H2 console access enabled

## 📊 Monitoring & Health Checks

All services include Spring Boot Actuator endpoints:
- `/actuator/health` - Health status
- `/actuator/info` - Application info
- `/actuator/metrics` - Application metrics

## 🐳 Docker Support (Coming Soon)

Each service will include:
- Individual Dockerfiles
- Docker Compose configuration
- Multi-stage builds for optimization

## 🧪 Testing

### Running Tests
```bash
mvn test
```

### Test Coverage
- Unit tests for service layers
- Integration tests for repositories
- API endpoint testing

## 📈 Future Enhancements

- [ ] Complete Order Service implementation
- [ ] API Gateway with Spring Cloud Gateway
- [ ] Eureka Server for service discovery
- [ ] Docker containerization
- [ ] Message queues (RabbitMQ/Kafka)
- [ ] Distributed tracing (Zipkin)
- [ ] Circuit breakers (Hystrix/Resilience4j)
- [ ] Configuration server (Spring Cloud Config)
- [ ] Database per service (PostgreSQL/MySQL)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 📞 Support

For questions and support, please open an issue in the GitHub repository.

---

**Built with ❤️ using Spring Boot and Microservices Architecture**

