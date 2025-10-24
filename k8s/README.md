# Kubernetes Deployment Guide

This directory contains all the Kubernetes manifests and deployment scripts for the Microservices CRUD Application.

## 🏗️ Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                        Kubernetes Cluster                       │
├─────────────────────────────────────────────────────────────────┤
│  ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐ │
│  │   Ingress       │    │   User Service  │    │ Product Service │ │
│  │   Controller    │    │   (2 replicas)  │    │   (2 replicas)  │ │
│  │                 │    │   Port: 8083    │    │   Port: 8081    │ │
│  └─────────────────┘    └─────────────────┘    └─────────────────┘ │
│           │                       │                       │        │
│           └───────────────────────┼───────────────────────┘        │
│                                   │                                │
│  ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐ │
│  │  Eureka Server  │    │   ConfigMaps    │    │    Secrets      │ │
│  │  (1 replica)    │    │   & Services    │    │   & Network     │ │
│  │  Port: 8761     │    │                 │    │   Policies      │ │
│  └─────────────────┘    └─────────────────┘    └─────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
```

## 📁 Directory Structure

```
k8s/
├── namespaces/
│   └── microservices-namespace.yaml    # Namespace, ResourceQuota, LimitRange
├── configmaps/
│   ├── user-service-config.yaml        # User Service configuration
│   └── product-service-config.yaml     # Product Service configuration
├── secrets/
│   └── app-secrets.yaml                # JWT secrets, DB passwords
├── deployments/
│   ├── user-service-deployment.yaml    # User Service deployment
│   ├── product-service-deployment.yaml # Product Service deployment
│   ├── eureka-server-deployment.yaml   # Eureka Server deployment
│   └── hpa.yaml                        # Horizontal Pod Autoscalers
├── services/
│   ├── user-service-service.yaml       # User Service ClusterIP service
│   ├── product-service-service.yaml    # Product Service ClusterIP service
│   └── eureka-server-service.yaml      # Eureka Server service
├── ingress/
│   └── microservices-ingress.yaml      # Nginx Ingress configuration
├── monitoring/
│   └── service-monitor.yaml            # Prometheus ServiceMonitor
├── network-policies.yaml               # Network security policies
├── deploy.sh                           # Deployment script
├── undeploy.sh                         # Cleanup script
└── README.md                           # This file
```

## 🚀 Quick Start

### Prerequisites

1. **Kubernetes Cluster**: Ensure you have access to a Kubernetes cluster
2. **kubectl**: Install and configure kubectl
3. **Docker**: For building container images
4. **Ingress Controller**: Nginx Ingress Controller (optional but recommended)

### Deploy the Application

```bash
# Navigate to k8s directory
cd k8s

# Deploy everything
./deploy.sh

# Or deploy without building images (if already built)
./deploy.sh --skip-build
```

### Access the Application

After deployment, you can access the services:

#### Using Port-Forward (Immediate Access)
```bash
# User Service
kubectl port-forward svc/user-service 8083:8083 -n microservices

# Product Service  
kubectl port-forward svc/product-service 8081:8081 -n microservices

# Eureka Server
kubectl port-forward svc/eureka-server 8761:8761 -n microservices
```

#### Using Ingress (Production-like Access)
1. Add to your `/etc/hosts`:
   ```
   <INGRESS_IP> microservices.local
   ```

2. Access endpoints:
   - User API: http://microservices.local/api/v1/users
   - Product API: http://microservices.local/api/v1/products
   - Eureka Dashboard: http://microservices.local/eureka
   - User Swagger: http://microservices.local/swagger/users/swagger-ui.html
   - Product Swagger: http://microservices.local/swagger/products/swagger-ui.html

## 🔧 Configuration Details

### Resource Allocation

| Service | CPU Request | Memory Request | CPU Limit | Memory Limit |
|---------|-------------|----------------|-----------|--------------|
| User Service | 200m | 256Mi | 500m | 512Mi |
| Product Service | 200m | 256Mi | 500m | 512Mi |
| Eureka Server | 200m | 256Mi | 500m | 512Mi |

### Health Checks

All services include comprehensive health checks:
- **Startup Probe**: Initial health check with longer timeout
- **Liveness Probe**: Detects if container needs restart
- **Readiness Probe**: Determines if pod can receive traffic

### Auto-scaling

Horizontal Pod Autoscalers are configured for:
- **User Service**: 2-10 replicas based on CPU (70%) and Memory (80%)
- **Product Service**: 2-10 replicas based on CPU (70%) and Memory (80%)

### Security

- **Network Policies**: Restrict inter-pod communication
- **Secrets Management**: JWT tokens and passwords stored securely
- **RBAC**: Proper service account permissions
- **Resource Limits**: Prevent resource exhaustion

## 📊 Monitoring

### Prometheus Integration

ServiceMonitor resources are included for Prometheus scraping:
- Metrics endpoint: `/actuator/prometheus`
- Scrape interval: 30 seconds
- Health metrics, JVM metrics, and custom application metrics

### Available Metrics Endpoints

```bash
# Health checks
curl http://microservices.local/api/v1/users/actuator/health
curl http://microservices.local/api/v1/products/actuator/health

# Prometheus metrics
curl http://microservices.local/api/v1/users/actuator/prometheus
curl http://microservices.local/api/v1/products/actuator/prometheus

# Application info
curl http://microservices.local/api/v1/users/actuator/info
curl http://microservices.local/api/v1/products/actuator/info
```

## 🛠️ Management Commands

### Scaling Services

```bash
# Scale User Service to 5 replicas
kubectl scale deployment user-service --replicas=5 -n microservices

# Scale Product Service to 3 replicas
kubectl scale deployment product-service --replicas=3 -n microservices
```

### Viewing Logs

```bash
# View User Service logs
kubectl logs -f deployment/user-service -n microservices

# View Product Service logs
kubectl logs -f deployment/product-service -n microservices

# View all pods logs
kubectl logs -f -l app=user-service -n microservices
```

### Debugging

```bash
# Get pod status
kubectl get pods -n microservices -o wide

# Describe a pod
kubectl describe pod <pod-name> -n microservices

# Execute into a pod
kubectl exec -it <pod-name> -n microservices -- /bin/bash

# Check service endpoints
kubectl get endpoints -n microservices
```

### Configuration Updates

```bash
# Update ConfigMap
kubectl apply -f configmaps/user-service-config.yaml

# Restart deployment to pick up new config
kubectl rollout restart deployment/user-service -n microservices

# Check rollout status
kubectl rollout status deployment/user-service -n microservices
```

## 🔄 Rolling Updates

```bash
# Update image
kubectl set image deployment/user-service user-service=user-service:v2 -n microservices

# Check rollout history
kubectl rollout history deployment/user-service -n microservices

# Rollback to previous version
kubectl rollout undo deployment/user-service -n microservices
```

## 🧹 Cleanup

### Remove All Resources

```bash
# Complete cleanup
./undeploy.sh

# Keep namespace but remove resources
./undeploy.sh --keep-namespace

# Force delete without confirmation
./undeploy.sh --force

# Also cleanup Docker images
./undeploy.sh --cleanup-images
```

### Selective Cleanup

```bash
# Delete specific deployment
kubectl delete deployment user-service -n microservices

# Delete all deployments but keep services
kubectl delete deployments --all -n microservices

# Delete namespace (removes everything)
kubectl delete namespace microservices
```

## 🔍 Troubleshooting

### Common Issues

1. **Pods not starting**
   ```bash
   kubectl describe pod <pod-name> -n microservices
   kubectl logs <pod-name> -n microservices
   ```

2. **Service discovery issues**
   ```bash
   # Check Eureka Server
   kubectl port-forward svc/eureka-server 8761:8761 -n microservices
   # Visit http://localhost:8761
   ```

3. **Ingress not working**
   ```bash
   # Check ingress controller
   kubectl get pods -n ingress-nginx
   
   # Check ingress resource
   kubectl describe ingress microservices-ingress -n microservices
   ```

4. **Database connection issues**
   ```bash
   # Check H2 console
   kubectl port-forward svc/user-service 8083:8083 -n microservices
   # Visit http://localhost:8083/h2-console
   ```

### Performance Tuning

1. **Adjust resource limits**
   ```yaml
   resources:
     requests:
       memory: "512Mi"
       cpu: "300m"
     limits:
       memory: "1Gi"
       cpu: "1000m"
   ```

2. **Tune JVM settings**
   ```yaml
   env:
   - name: JAVA_OPTS
     value: "-Xms256m -Xmx512m -XX:+UseG1GC"
   ```

3. **Adjust HPA settings**
   ```yaml
   metrics:
   - type: Resource
     resource:
       name: cpu
       target:
         type: Utilization
         averageUtilization: 60  # Lower threshold for faster scaling
   ```

## 🔐 Security Considerations

1. **Secrets Management**: Use external secret management systems in production
2. **Network Policies**: Review and adjust network policies for your environment
3. **RBAC**: Implement proper role-based access control
4. **Image Security**: Scan container images for vulnerabilities
5. **Pod Security**: Use Pod Security Standards/Policies

## 🚀 Production Readiness

For production deployment, consider:

1. **Persistent Storage**: Replace H2 with PostgreSQL/MySQL
2. **External Configuration**: Use external config management
3. **Monitoring**: Deploy Prometheus, Grafana, and alerting
4. **Logging**: Centralized logging with ELK stack
5. **Backup**: Database backup strategies
6. **High Availability**: Multi-zone deployment
7. **Security**: Network policies, Pod security policies
8. **CI/CD**: Automated deployment pipelines

## 📚 Additional Resources

- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Spring Boot on Kubernetes](https://spring.io/guides/gs/spring-boot-kubernetes/)
- [Prometheus Monitoring](https://prometheus.io/docs/)
- [Nginx Ingress Controller](https://kubernetes.github.io/ingress-nginx/)

