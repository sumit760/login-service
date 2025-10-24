package com.example.product.controller;

import com.example.product.model.Product;
import com.example.product.service.ProductService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/api/v1/products")
@Tag(name = "Product Management", description = "Product CRUD operations")
public class ProductController {
    
    private static final Logger logger = LoggerFactory.getLogger(ProductController.class);
    
    @Autowired
    private ProductService productService;
    
    @GetMapping
    @Operation(summary = "Get all products", description = "Retrieve all products")
    public ResponseEntity<List<Product>> getAllProducts() {
        logger.info("Fetching all products");
        List<Product> products = productService.getAllProducts();
        return ResponseEntity.ok(products);
    }
    
    @GetMapping("/{id}")
    @Operation(summary = "Get product by ID", description = "Retrieve a product by its ID")
    public ResponseEntity<?> getProductById(@PathVariable Long id) {
        logger.info("Fetching product by id: {}", id);
        
        Optional<Product> product = productService.getProductById(id);
        if (product.isPresent()) {
            return ResponseEntity.ok(product.get());
        }
        
        return ResponseEntity.status(HttpStatus.NOT_FOUND).body("Product not found with id: " + id);
    }
    
    @PostMapping
    @Operation(summary = "Create product", description = "Create a new product")
    public ResponseEntity<?> createProduct(@Valid @RequestBody Product product) {
        logger.info("Creating new product: {}", product.getName());
        
        try {
            Product savedProduct = productService.createProduct(product);
            return ResponseEntity.status(HttpStatus.CREATED).body(savedProduct);
        } catch (Exception e) {
            logger.error("Error creating product: {}", e.getMessage());
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("Failed to create product: " + e.getMessage());
        }
    }
    
    @PutMapping("/{id}")
    @Operation(summary = "Update product", description = "Update an existing product")
    public ResponseEntity<?> updateProduct(@PathVariable Long id, @Valid @RequestBody Product productDetails) {
        logger.info("Updating product with id: {}", id);
        
        try {
            Product updatedProduct = productService.updateProduct(id, productDetails);
            return ResponseEntity.ok(updatedProduct);
        } catch (Exception e) {
            logger.error("Error updating product {}: {}", id, e.getMessage());
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("Failed to update product: " + e.getMessage());
        }
    }
    
    @DeleteMapping("/{id}")
    @Operation(summary = "Delete product", description = "Delete a product by ID")
    public ResponseEntity<?> deleteProduct(@PathVariable Long id) {
        logger.info("Deleting product with id: {}", id);
        
        try {
            productService.deleteProduct(id);
            return ResponseEntity.ok("Product deleted successfully");
        } catch (Exception e) {
            logger.error("Error deleting product {}: {}", id, e.getMessage());
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body("Failed to delete product: " + e.getMessage());
        }
    }
    
    @GetMapping("/category/{category}")
    @Operation(summary = "Get products by category", description = "Retrieve products by category")
    public ResponseEntity<List<Product>> getProductsByCategory(@PathVariable String category) {
        logger.info("Fetching products by category: {}", category);
        List<Product> products = productService.getProductsByCategory(category);
        return ResponseEntity.ok(products);
    }
    
    @GetMapping("/search")
    @Operation(summary = "Search products", description = "Search products by name")
    public ResponseEntity<List<Product>> searchProducts(@RequestParam String name) {
        logger.info("Searching products by name: {}", name);
        List<Product> products = productService.searchProductsByName(name);
        return ResponseEntity.ok(products);
    }
    
    @GetMapping("/available")
    @Operation(summary = "Get available products", description = "Retrieve products that are in stock and active")
    public ResponseEntity<List<Product>> getAvailableProducts() {
        logger.info("Fetching available products");
        List<Product> products = productService.getAvailableProducts();
        return ResponseEntity.ok(products);
    }
    
    @GetMapping("/price-range")
    @Operation(summary = "Get products by price range", description = "Retrieve products within a price range")
    public ResponseEntity<List<Product>> getProductsByPriceRange(
            @RequestParam BigDecimal minPrice, 
            @RequestParam BigDecimal maxPrice) {
        logger.info("Fetching products by price range: {} - {}", minPrice, maxPrice);
        List<Product> products = productService.getProductsByPriceRange(minPrice, maxPrice);
        return ResponseEntity.ok(products);
    }
    
    @PatchMapping("/{id}/stock")
    @Operation(summary = "Update product stock", description = "Update product stock quantity")
    public ResponseEntity<?> updateStock(@PathVariable Long id, @RequestParam Integer quantity) {
        logger.info("Updating stock for product {}: {}", id, quantity);
        
        try {
            Product updatedProduct = productService.updateStock(id, quantity);
            return ResponseEntity.ok(updatedProduct);
        } catch (Exception e) {
            logger.error("Error updating stock for product {}: {}", id, e.getMessage());
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("Failed to update stock: " + e.getMessage());
        }
    }
}

