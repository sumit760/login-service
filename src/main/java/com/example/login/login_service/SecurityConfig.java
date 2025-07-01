package com.example.login.login_service;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.Customizer;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.web.SecurityFilterChain;

@Configuration
@EnableWebSecurity
public class SecurityConfig {

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
            .authorizeHttpRequests(auth -> auth
                .requestMatchers("/api/v1/login").permitAll()
                .anyRequest().authenticated()
            )
            .csrf(csrf -> csrf.disable()) // new lambda style
            .httpBasic(Customizer.withDefaults())
            .formLogin(form -> form.disable()); // disable default login form

        return http.build();
    }
}
