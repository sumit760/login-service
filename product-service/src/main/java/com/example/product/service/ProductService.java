package com.example.product.service;

import com.example.product.model.Product;
import com.example.product.repository.ProductRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.List;
import java.util.Optional;

@Service
@Transactional
public class ProductService {
    
    private static final Logger logger = LoggerFactory.getLogger(ProductService.class);
    
    @Autowired
    private ProductRepository productRepository;
    
    public List<Product> getAllProducts() {
        logger.info("Fetching all products");
        return productRepository.findAll();
    }
    
    public Optional<Product> getProductById(Long id) {
        logger.info("Fetching product by id: {}", id);
        return productRepository.findById(id);
    }
    
    public Optional<Product> getProductBySku(String sku) {
        logger.info("Fetching product by SKU: {}", sku);
        return productRepository.findBySku(sku);
    }
    
    public Product createProduct(Product product) {
        logger.info("Creating new product: {}", product.getName());
        
        // Check if SKU already exists
        if (productRepository.existsBySku(product.getSku())) {
            throw new RuntimeException("Product with SKU already exists: " + product.getSku());
        }
        
        Product savedProduct = productRepository.save(product);
        logger.info("Product created successfully with id: {}", savedProduct.getId());
        return savedProduct;
    }
    
    public Product updateProduct(Long id, Product productDetails) {
        logger.info("Updating product with id: {}", id);
        
        Product product = productRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Product not found with id: " + id));
        
        // Update fields
        product.setName(productDetails.getName());
        product.setDescription(productDetails.getDescription());
        product.setPrice(productDetails.getPrice());
        product.setCategory(productDetails.getCategory());
        product.setStockQuantity(productDetails.getStockQuantity());
        product.setIsActive(productDetails.getIsActive());
        product.setImageUrl(productDetails.getImageUrl());
        product.setWeight(productDetails.getWeight());
        product.setDimensions(productDetails.getDimensions());
        
        Product updatedProduct = productRepository.save(product);
        logger.info("Product updated successfully: {}", updatedProduct.getId());
        return updatedProduct;
    }
    
    public void deleteProduct(Long id) {
        logger.info("Deleting product with id: {}", id);
        
        Product product = productRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Product not found with id: " + id));
        
        productRepository.delete(product);
        logger.info("Product deleted successfully: {}", id);
    }
    
    public List<Product> getProductsByCategory(String category) {
        logger.info("Fetching products by category: {}", category);
        return productRepository.findByCategory(category);
    }
    
    public List<Product> searchProductsByName(String name) {
        logger.info("Searching products by name: {}", name);
        return productRepository.findByNameContaining(name);
    }
    
    public List<Product> getAvailableProducts() {
        logger.info("Fetching available products");
        return productRepository.findAvailableProducts();
    }
    
    public List<Product> getProductsByPriceRange(BigDecimal minPrice, BigDecimal maxPrice) {
        logger.info("Fetching products by price range: {} - {}", minPrice, maxPrice);
        return productRepository.findByPriceBetween(minPrice, maxPrice);
    }
    
    public List<Product> getLowStockProducts(Integer threshold) {
        logger.info("Fetching low stock products with threshold: {}", threshold);
        return productRepository.findLowStockProducts(threshold);
    }
    
    public Product updateStock(Long id, Integer quantity) {
        logger.info("Updating stock for product {}: {}", id, quantity);
        
        Product product = productRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Product not found with id: " + id));
        
        product.setStockQuantity(quantity);
        Product updatedProduct = productRepository.save(product);
        logger.info("Stock updated successfully for product: {}", id);
        return updatedProduct;
    }
    
    public Product adjustStock(Long id, Integer adjustment) {
        logger.info("Adjusting stock for product {}: {}", id, adjustment);
        
        Product product = productRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Product not found with id: " + id));
        
        int newQuantity = product.getStockQuantity() + adjustment;
        if (newQuantity < 0) {
            throw new RuntimeException("Insufficient stock. Current: " + product.getStockQuantity() + ", Requested: " + Math.abs(adjustment));
        }
        
        product.setStockQuantity(newQuantity);
        Product updatedProduct = productRepository.save(product);
        logger.info("Stock adjusted successfully for product: {}", id);
        return updatedProduct;
    }
}

