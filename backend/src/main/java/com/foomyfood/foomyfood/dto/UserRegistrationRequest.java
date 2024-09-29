package com.foomyfood.foomyfood.dto;

public class UserRegistrationRequest {

    private String email;
    private String username;

    // 构造函数
    public UserRegistrationRequest() {
    }

    public UserRegistrationRequest(String email, String username) {
        this.email = email;
        this.username = username;
    }

    // Getter and Setter for email
    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    // Getter and Setter for username
    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }
}
