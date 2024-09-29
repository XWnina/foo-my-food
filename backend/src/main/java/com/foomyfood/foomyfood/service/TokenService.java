package com.foomyfood.foomyfood.service;

import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

@Service
public class TokenService {

    private final Map<String, String> tokenStore = new HashMap<>();

    public String generateToken(String email) {
        String token = UUID.randomUUID().toString();
        tokenStore.put(token, email);
        return token;
    }

    public String validateToken(String token) {
        if (tokenStore.containsKey(token)) {
            return tokenStore.get(token);
        } else {
            throw new RuntimeException("Invalid token");
        }
    }
}
