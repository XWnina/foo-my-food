package com.foomyfood.foomyfood.dto;

public class PasswordResetRequest {
    private String email;
    private String userName;  // 新增用户名字段

    // Getters and setters
    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getUserName() {
        return userName;
    }

}

