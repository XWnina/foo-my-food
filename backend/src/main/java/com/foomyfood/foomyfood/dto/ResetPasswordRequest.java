package com.foomyfood.foomyfood.dto;

public class ResetPasswordRequest {
    private String token;
    private String newPassword;

    public String getToken() {
        return this.token = token;
    }

    public String getNewPassword() {
        return this.newPassword = newPassword;
    }

    // Getters and setters
}
