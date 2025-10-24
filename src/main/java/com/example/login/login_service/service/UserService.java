package com.example.login.login_service.service;

import com.example.login.login_service.model.User;
import com.example.login.login_service.repository.UserRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;

@Service
@Transactional
public class UserService {
    
    private static final Logger logger = LoggerFactory.getLogger(UserService.class);
    
    @Autowired
    private UserRepository userRepository;
    
    @Autowired
    private PasswordEncoder passwordEncoder;
    
    public List<User> getAllUsers() {
        logger.info("Fetching all users");
        return userRepository.findAll();
    }
    
    public Optional<User> getUserById(Long id) {
        logger.info("Fetching user by id: {}", id);
        return userRepository.findById(id);
    }
    
    public Optional<User> getUserByUsername(String username) {
        logger.info("Fetching user by username: {}", username);
        return userRepository.findByUsername(username);
    }
    
    public Optional<User> getUserByEmail(String email) {
        logger.info("Fetching user by email: {}", email);
        return userRepository.findByEmail(email);
    }
    
    public User createUser(User user) {
        logger.info("Creating new user: {}", user.getUsername());
        
        // Check if username or email already exists
        if (userRepository.existsByUsername(user.getUsername())) {
            throw new RuntimeException("Username already exists: " + user.getUsername());
        }
        
        if (userRepository.existsByEmail(user.getEmail())) {
            throw new RuntimeException("Email already exists: " + user.getEmail());
        }
        
        // Encode password
        user.setPassword(passwordEncoder.encode(user.getPassword()));
        
        User savedUser = userRepository.save(user);
        logger.info("User created successfully with id: {}", savedUser.getId());
        return savedUser;
    }
    
    public User updateUser(Long id, User userDetails) {
        logger.info("Updating user with id: {}", id);
        
        User user = userRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("User not found with id: " + id));
        
        // Update fields
        user.setFirstName(userDetails.getFirstName());
        user.setLastName(userDetails.getLastName());
        user.setEmail(userDetails.getEmail());
        user.setPhoneNumber(userDetails.getPhoneNumber());
        user.setIsActive(userDetails.getIsActive());
        
        // Only update password if provided
        if (userDetails.getPassword() != null && !userDetails.getPassword().isEmpty()) {
            user.setPassword(passwordEncoder.encode(userDetails.getPassword()));
        }
        
        User updatedUser = userRepository.save(user);
        logger.info("User updated successfully: {}", updatedUser.getId());
        return updatedUser;
    }
    
    public void deleteUser(Long id) {
        logger.info("Deleting user with id: {}", id);
        
        User user = userRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("User not found with id: " + id));
        
        userRepository.delete(user);
        logger.info("User deleted successfully: {}", id);
    }
    
    public void deactivateUser(Long id) {
        logger.info("Deactivating user with id: {}", id);
        
        User user = userRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("User not found with id: " + id));
        
        user.setIsActive(false);
        userRepository.save(user);
        logger.info("User deactivated successfully: {}", id);
    }
    
    public void activateUser(Long id) {
        logger.info("Activating user with id: {}", id);
        
        User user = userRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("User not found with id: " + id));
        
        user.setIsActive(true);
        userRepository.save(user);
        logger.info("User activated successfully: {}", id);
    }
    
    public List<User> getActiveUsers() {
        logger.info("Fetching active users");
        return userRepository.findByIsActiveTrue();
    }
    
    public List<User> searchUsersByName(String name) {
        logger.info("Searching users by name: {}", name);
        return userRepository.findByNameContaining(name);
    }
    
    public boolean validateUser(String username, String password) {
        logger.info("Validating user: {}", username);
        
        Optional<User> userOpt = userRepository.findByUsername(username);
        if (userOpt.isPresent()) {
            User user = userOpt.get();
            boolean isValid = passwordEncoder.matches(password, user.getPassword()) && user.getIsActive();
            logger.info("User validation result for {}: {}", username, isValid);
            return isValid;
        }
        
        logger.warn("User not found: {}", username);
        return false;
    }
}

