package com.example.login.login_service;

import com.example.login.login_service.dto.LoginResponse;
import com.example.login.login_service.dto.UserRegistrationRequest;
import com.example.login.login_service.dto.UserResponse;
import com.example.login.login_service.model.User;
import com.example.login.login_service.service.JwtService;
import com.example.login.login_service.service.UserService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import org.springframework.http.ResponseEntity;
import org.springframework.http.HttpStatus;
import jakarta.validation.Valid;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/v1")
@Tag(name = "User Management", description = "User authentication and CRUD operations")
public class LoginController {

    private static final Logger logger = LoggerFactory.getLogger(LoginController.class);

    @Autowired
    private UserService userService;
    
    @Autowired
    private JwtService jwtService;

    @PostMapping("/login")
    @Operation(summary = "User login", description = "Authenticate user and return JWT token")
    public ResponseEntity<?> login(@Valid @RequestBody LoginRequest request) {
        logger.info("Login attempt for user: {}", request.getUsername());

        try {
            if (userService.validateUser(request.getUsername(), request.getPassword())) {
                Optional<User> userOpt = userService.getUserByUsername(request.getUsername());
                if (userOpt.isPresent()) {
                    User user = userOpt.get();
                    String token = jwtService.generateToken(user.getUsername(), user.getId());
                    
                    LoginResponse response = new LoginResponse(
                        token, 
                        user.getId(), 
                        user.getUsername(), 
                        user.getEmail(),
                        user.getFirstName(), 
                        user.getLastName()
                    );
                    
                    logger.info("Login successful for user: {}", request.getUsername());
                    return ResponseEntity.ok(response);
                }
            }
        } catch (Exception e) {
            logger.error("Login error for user {}: {}", request.getUsername(), e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("Login failed: " + e.getMessage());
        }

        logger.warn("Invalid login attempt for user: {}", request.getUsername());
        return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Invalid credentials");
    }
    
    @PostMapping("/register")
    @Operation(summary = "User registration", description = "Register a new user")
    public ResponseEntity<?> register(@Valid @RequestBody UserRegistrationRequest request) {
        logger.info("Registration attempt for user: {}", request.getUsername());
        
        try {
            User user = new User(
                request.getUsername(),
                request.getEmail(),
                request.getPassword(),
                request.getFirstName(),
                request.getLastName()
            );
            user.setPhoneNumber(request.getPhoneNumber());
            
            User savedUser = userService.createUser(user);
            UserResponse response = new UserResponse(savedUser);
            
            logger.info("User registered successfully: {}", savedUser.getUsername());
            return ResponseEntity.status(HttpStatus.CREATED).body(response);
            
        } catch (Exception e) {
            logger.error("Registration error for user {}: {}", request.getUsername(), e.getMessage());
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("Registration failed: " + e.getMessage());
        }
    }
    
    @GetMapping("/users")
    @Operation(summary = "Get all users", description = "Retrieve all users")
    public ResponseEntity<List<UserResponse>> getAllUsers() {
        logger.info("Fetching all users");
        
        List<User> users = userService.getAllUsers();
        List<UserResponse> response = users.stream()
                .map(UserResponse::new)
                .collect(Collectors.toList());
        
        return ResponseEntity.ok(response);
    }
    
    @GetMapping("/users/{id}")
    @Operation(summary = "Get user by ID", description = "Retrieve a user by their ID")
    public ResponseEntity<?> getUserById(@PathVariable Long id) {
        logger.info("Fetching user by id: {}", id);
        
        Optional<User> userOpt = userService.getUserById(id);
        if (userOpt.isPresent()) {
            UserResponse response = new UserResponse(userOpt.get());
            return ResponseEntity.ok(response);
        }
        
        return ResponseEntity.status(HttpStatus.NOT_FOUND).body("User not found with id: " + id);
    }
    
    @PutMapping("/users/{id}")
    @Operation(summary = "Update user", description = "Update an existing user")
    public ResponseEntity<?> updateUser(@PathVariable Long id, @Valid @RequestBody UserRegistrationRequest request) {
        logger.info("Updating user with id: {}", id);
        
        try {
            User userDetails = new User();
            userDetails.setFirstName(request.getFirstName());
            userDetails.setLastName(request.getLastName());
            userDetails.setEmail(request.getEmail());
            userDetails.setPhoneNumber(request.getPhoneNumber());
            userDetails.setPassword(request.getPassword());
            userDetails.setIsActive(true);
            
            User updatedUser = userService.updateUser(id, userDetails);
            UserResponse response = new UserResponse(updatedUser);
            
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            logger.error("Update error for user {}: {}", id, e.getMessage());
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("Update failed: " + e.getMessage());
        }
    }
    
    @DeleteMapping("/users/{id}")
    @Operation(summary = "Delete user", description = "Delete a user by ID")
    public ResponseEntity<?> deleteUser(@PathVariable Long id) {
        logger.info("Deleting user with id: {}", id);
        
        try {
            userService.deleteUser(id);
            return ResponseEntity.ok("User deleted successfully");
        } catch (Exception e) {
            logger.error("Delete error for user {}: {}", id, e.getMessage());
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body("Delete failed: " + e.getMessage());
        }
    }
    
    @PatchMapping("/users/{id}/deactivate")
    @Operation(summary = "Deactivate user", description = "Deactivate a user account")
    public ResponseEntity<?> deactivateUser(@PathVariable Long id) {
        logger.info("Deactivating user with id: {}", id);
        
        try {
            userService.deactivateUser(id);
            return ResponseEntity.ok("User deactivated successfully");
        } catch (Exception e) {
            logger.error("Deactivation error for user {}: {}", id, e.getMessage());
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body("Deactivation failed: " + e.getMessage());
        }
    }
    
    @PatchMapping("/users/{id}/activate")
    @Operation(summary = "Activate user", description = "Activate a user account")
    public ResponseEntity<?> activateUser(@PathVariable Long id) {
        logger.info("Activating user with id: {}", id);
        
        try {
            userService.activateUser(id);
            return ResponseEntity.ok("User activated successfully");
        } catch (Exception e) {
            logger.error("Activation error for user {}: {}", id, e.getMessage());
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body("Activation failed: " + e.getMessage());
        }
    }
    
    @GetMapping("/users/active")
    @Operation(summary = "Get active users", description = "Retrieve all active users")
    public ResponseEntity<List<UserResponse>> getActiveUsers() {
        logger.info("Fetching active users");
        
        List<User> users = userService.getActiveUsers();
        List<UserResponse> response = users.stream()
                .map(UserResponse::new)
                .collect(Collectors.toList());
        
        return ResponseEntity.ok(response);
    }
    
    @GetMapping("/users/search")
    @Operation(summary = "Search users by name", description = "Search users by first or last name")
    public ResponseEntity<List<UserResponse>> searchUsers(@RequestParam String name) {
        logger.info("Searching users by name: {}", name);
        
        List<User> users = userService.searchUsersByName(name);
        List<UserResponse> response = users.stream()
                .map(UserResponse::new)
                .collect(Collectors.toList());
        
        return ResponseEntity.ok(response);
    }
}
