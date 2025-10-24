#!/bin/bash

# Kubernetes Undeployment Script for Microservices CRUD Application
echo "🗑️  Undeploying Microservices CRUD Application from Kubernetes"
echo "=============================================================="

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

# Function to check if namespace exists
check_namespace() {
    if ! kubectl get namespace microservices &> /dev/null; then
        echo -e "${YELLOW}Namespace 'microservices' does not exist${NC}"
        exit 0
    fi
    echo -e "${GREEN}✓ Namespace 'microservices' exists${NC}"
}

# Function to delete resources in order
delete_resources() {
    echo -e "\n${YELLOW}Deleting Kubernetes resources...${NC}"
    
    # Delete ingress first
    echo -e "${BLUE}Deleting ingress...${NC}"
    kubectl delete -f k8s/ingress/ --ignore-not-found=true
    
    # Delete monitoring resources
    echo -e "${BLUE}Deleting monitoring resources...${NC}"
    kubectl delete -f k8s/monitoring/ --ignore-not-found=true
    
    # Delete network policies
    echo -e "${BLUE}Deleting network policies...${NC}"
    kubectl delete -f k8s/network-policies.yaml --ignore-not-found=true
    
    # Delete HPA
    echo -e "${BLUE}Deleting Horizontal Pod Autoscalers...${NC}"
    kubectl delete -f k8s/deployments/hpa.yaml --ignore-not-found=true
    
    # Delete deployments
    echo -e "${BLUE}Deleting deployments...${NC}"
    kubectl delete -f k8s/deployments/ --ignore-not-found=true
    
    # Wait for pods to terminate
    echo -e "${YELLOW}Waiting for pods to terminate...${NC}"
    kubectl wait --for=delete pods --all -n microservices --timeout=120s
    
    # Delete services
    echo -e "${BLUE}Deleting services...${NC}"
    kubectl delete -f k8s/services/ --ignore-not-found=true
    
    # Delete configmaps
    echo -e "${BLUE}Deleting configmaps...${NC}"
    kubectl delete -f k8s/configmaps/ --ignore-not-found=true
    
    # Delete secrets
    echo -e "${BLUE}Deleting secrets...${NC}"
    kubectl delete -f k8s/secrets/ --ignore-not-found=true
    
    echo -e "${GREEN}✓ Resources deleted successfully${NC}"
}

# Function to delete namespace
delete_namespace() {
    echo -e "\n${YELLOW}Deleting namespace...${NC}"
    kubectl delete -f k8s/namespaces/microservices-namespace.yaml --ignore-not-found=true
    
    # Wait for namespace to be deleted
    echo -e "${YELLOW}Waiting for namespace to be deleted...${NC}"
    kubectl wait --for=delete namespace/microservices --timeout=120s
    
    echo -e "${GREEN}✓ Namespace deleted successfully${NC}"
}

# Function to clean up Docker images (optional)
cleanup_images() {
    echo -e "\n${YELLOW}Cleaning up Docker images...${NC}"
    
    read -p "Do you want to delete the Docker images? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${BLUE}Deleting Docker images...${NC}"
        docker rmi user-service:latest 2>/dev/null || echo -e "${YELLOW}user-service:latest image not found${NC}"
        docker rmi product-service:latest 2>/dev/null || echo -e "${YELLOW}product-service:latest image not found${NC}"
        docker rmi eureka-server:latest 2>/dev/null || echo -e "${YELLOW}eureka-server:latest image not found${NC}"
        echo -e "${GREEN}✓ Docker images cleaned up${NC}"
    else
        echo -e "${YELLOW}Skipping Docker image cleanup${NC}"
    fi
}

# Function to show final status
show_final_status() {
    echo -e "\n${GREEN}🎉 Undeployment completed successfully!${NC}"
    echo -e "\n${YELLOW}Verification:${NC}"
    
    # Check if namespace still exists
    if kubectl get namespace microservices &> /dev/null; then
        echo -e "${RED}⚠️  Namespace 'microservices' still exists${NC}"
        echo -e "Remaining resources:"
        kubectl get all -n microservices
    else
        echo -e "${GREEN}✓ Namespace 'microservices' has been deleted${NC}"
    fi
    
    echo -e "\n${YELLOW}To redeploy:${NC}"
    echo -e "cd k8s && ./deploy.sh"
}

# Main execution
main() {
    echo -e "${BLUE}Checking prerequisites...${NC}"
    check_kubectl
    check_namespace
    
    # Parse command line arguments
    FORCE_DELETE=false
    KEEP_NAMESPACE=false
    CLEANUP_IMAGES=false
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            --force)
                FORCE_DELETE=true
                shift
                ;;
            --keep-namespace)
                KEEP_NAMESPACE=true
                shift
                ;;
            --cleanup-images)
                CLEANUP_IMAGES=true
                shift
                ;;
            --help)
                echo "Usage: $0 [--force] [--keep-namespace] [--cleanup-images] [--help]"
                echo "  --force           Force delete without confirmation"
                echo "  --keep-namespace  Keep the namespace after deleting resources"
                echo "  --cleanup-images  Clean up Docker images"
                echo "  --help            Show this help message"
                exit 0
                ;;
            *)
                echo "Unknown option $1"
                exit 1
                ;;
        esac
    done
    
    # Confirmation prompt unless force delete
    if [ "$FORCE_DELETE" = false ]; then
        echo -e "\n${RED}⚠️  This will delete all microservices resources in the 'microservices' namespace${NC}"
        read -p "Are you sure you want to continue? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo -e "${YELLOW}Undeployment cancelled${NC}"
            exit 0
        fi
    fi
    
    delete_resources
    
    if [ "$KEEP_NAMESPACE" = false ]; then
        delete_namespace
    else
        echo -e "${YELLOW}Keeping namespace as requested${NC}"
    fi
    
    if [ "$CLEANUP_IMAGES" = true ]; then
        cleanup_images
    fi
    
    show_final_status
}

# Run main function
main "$@"

