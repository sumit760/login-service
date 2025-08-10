#!/bin/bash

# Kubernetes Deployment Script for Microservices CRUD Application
echo "🚀 Deploying Microservices CRUD Application to Kubernetes"
echo "=========================================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to check if kubectl is available
check_kubectl() {
    if ! command -v kubectl &> /dev/null; then
        echo -e "${RED}kubectl is not installed or not in PATH${NC}"
        exit 1
    fi
    echo -e "${GREEN}✓ kubectl is available${NC}"
}

# Function to check if cluster is accessible
check_cluster() {
    if ! kubectl cluster-info &> /dev/null; then
        echo -e "${RED}Cannot connect to Kubernetes cluster${NC}"
        exit 1
    fi
    echo -e "${GREEN}✓ Kubernetes cluster is accessible${NC}"
}

# Function to build Docker images
build_images() {
    echo -e "\n${YELLOW}Building Docker images...${NC}"
    
    # Build User Service
    echo -e "${BLUE}Building user-service image...${NC}"
    docker build -t user-service:latest . || {
        echo -e "${RED}Failed to build user-service image${NC}"
        exit 1
    }
    
    # Build Product Service
    echo -e "${BLUE}Building product-service image...${NC}"
    docker build -t product-service:latest ./product-service || {
        echo -e "${RED}Failed to build product-service image${NC}"
        exit 1
    }
    
    echo -e "${GREEN}✓ Docker images built successfully${NC}"
}

# Function to deploy Kubernetes resources
deploy_k8s_resources() {
    echo -e "\n${YELLOW}Deploying Kubernetes resources...${NC}"
    
    # Deploy namespace and RBAC
    echo -e "${BLUE}Creating namespace...${NC}"
    kubectl apply -f k8s/namespaces/microservices-namespace.yaml
    
    # Deploy secrets
    echo -e "${BLUE}Creating secrets...${NC}"
    kubectl apply -f k8s/secrets/app-secrets.yaml
    
    # Deploy configmaps
    echo -e "${BLUE}Creating configmaps...${NC}"
    kubectl apply -f k8s/configmaps/
    
    # Deploy services first (for DNS resolution)
    echo -e "${BLUE}Creating services...${NC}"
    kubectl apply -f k8s/services/
    
    # Deploy Eureka Server first
    echo -e "${BLUE}Deploying Eureka Server...${NC}"
    kubectl apply -f k8s/deployments/eureka-server-deployment.yaml
    
    # Wait for Eureka Server to be ready
    echo -e "${YELLOW}Waiting for Eureka Server to be ready...${NC}"
    kubectl wait --for=condition=available --timeout=300s deployment/eureka-server -n microservices
    
    # Deploy microservices
    echo -e "${BLUE}Deploying microservices...${NC}"
    kubectl apply -f k8s/deployments/user-service-deployment.yaml
    kubectl apply -f k8s/deployments/product-service-deployment.yaml
    
    # Deploy HPA
    echo -e "${BLUE}Creating Horizontal Pod Autoscalers...${NC}"
    kubectl apply -f k8s/deployments/hpa.yaml
    
    # Deploy network policies
    echo -e "${BLUE}Creating network policies...${NC}"
    kubectl apply -f k8s/network-policies.yaml
    
    # Deploy ingress
    echo -e "${BLUE}Creating ingress...${NC}"
    kubectl apply -f k8s/ingress/microservices-ingress.yaml
    
    # Deploy monitoring (if Prometheus is available)
    if kubectl get crd servicemonitors.monitoring.coreos.com &> /dev/null; then
        echo -e "${BLUE}Creating service monitors...${NC}"
        kubectl apply -f k8s/monitoring/service-monitor.yaml
    else
        echo -e "${YELLOW}Prometheus CRDs not found, skipping ServiceMonitor creation${NC}"
    fi
    
    echo -e "${GREEN}✓ Kubernetes resources deployed successfully${NC}"
}

# Function to wait for deployments
wait_for_deployments() {
    echo -e "\n${YELLOW}Waiting for deployments to be ready...${NC}"
    
    kubectl wait --for=condition=available --timeout=300s deployment/user-service -n microservices
    kubectl wait --for=condition=available --timeout=300s deployment/product-service -n microservices
    
    echo -e "${GREEN}✓ All deployments are ready${NC}"
}

# Function to display deployment status
show_status() {
    echo -e "\n${YELLOW}Deployment Status:${NC}"
    echo -e "\n${BLUE}Pods:${NC}"
    kubectl get pods -n microservices -o wide
    
    echo -e "\n${BLUE}Services:${NC}"
    kubectl get services -n microservices
    
    echo -e "\n${BLUE}Ingress:${NC}"
    kubectl get ingress -n microservices
    
    echo -e "\n${BLUE}HPA Status:${NC}"
    kubectl get hpa -n microservices
}

# Function to display access information
show_access_info() {
    echo -e "\n${GREEN}🎉 Deployment completed successfully!${NC}"
    echo -e "\n${YELLOW}Access Information:${NC}"
    
    # Get ingress IP
    INGRESS_IP=$(kubectl get ingress microservices-ingress -n microservices -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null)
    if [ -z "$INGRESS_IP" ]; then
        INGRESS_IP=$(kubectl get ingress microservices-ingress -n microservices -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null)
    fi
    
    if [ -z "$INGRESS_IP" ]; then
        echo -e "${YELLOW}Ingress IP not yet assigned. Using port-forward for access:${NC}"
        echo -e "User Service:    kubectl port-forward svc/user-service 8083:8083 -n microservices"
        echo -e "Product Service: kubectl port-forward svc/product-service 8081:8081 -n microservices"
        echo -e "Eureka Server:   kubectl port-forward svc/eureka-server 8761:8761 -n microservices"
    else
        echo -e "Add this to your /etc/hosts file:"
        echo -e "${INGRESS_IP} microservices.local"
        echo -e "\nThen access:"
        echo -e "User API:        http://microservices.local/api/v1/users"
        echo -e "Product API:     http://microservices.local/api/v1/products"
        echo -e "Eureka Server:   http://microservices.local/eureka"
        echo -e "User Swagger:    http://microservices.local/swagger/users/swagger-ui.html"
        echo -e "Product Swagger: http://microservices.local/swagger/products/swagger-ui.html"
    fi
    
    echo -e "\n${YELLOW}Useful Commands:${NC}"
    echo -e "View logs:       kubectl logs -f deployment/user-service -n microservices"
    echo -e "Scale service:   kubectl scale deployment user-service --replicas=3 -n microservices"
    echo -e "Delete all:      kubectl delete namespace microservices"
}

# Main execution
main() {
    echo -e "${BLUE}Checking prerequisites...${NC}"
    check_kubectl
    check_cluster
    
    # Parse command line arguments
    BUILD_IMAGES=true
    SKIP_BUILD=false
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            --skip-build)
                SKIP_BUILD=true
                shift
                ;;
            --help)
                echo "Usage: $0 [--skip-build] [--help]"
                echo "  --skip-build  Skip Docker image building"
                echo "  --help        Show this help message"
                exit 0
                ;;
            *)
                echo "Unknown option $1"
                exit 1
                ;;
        esac
    done
    
    if [ "$SKIP_BUILD" = false ]; then
        build_images
    else
        echo -e "${YELLOW}Skipping Docker image build${NC}"
    fi
    
    deploy_k8s_resources
    wait_for_deployments
    show_status
    show_access_info
}

# Run main function
main "$@"

