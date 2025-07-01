package com.example.login.login_service;

import org.springframework.web.bind.annotation.*;
import org.springframework.http.ResponseEntity;
import org.springframework.http.HttpStatus;
import jakarta.validation.Valid;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

@RestController
@RequestMapping("/api/v1/login")
class LoginController {

    private static final Logger logger = LoggerFactory.getLogger(LoginController.class);

    @PostMapping
    public ResponseEntity<String> login(@Valid @RequestBody LoginRequest request) {
        logger.info("Login attempt for user: {}", request.getUsername());

        if ("user".equals(request.getUsername()) && "pass".equals(request.getPassword())) {
            logger.info("Login successful for user: {}", request.getUsername());
            return ResponseEntity.ok("Login successful");
        }

        logger.warn("Invalid login attempt for user: {}", request.getUsername());
        return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Invalid credentials");
    }
}