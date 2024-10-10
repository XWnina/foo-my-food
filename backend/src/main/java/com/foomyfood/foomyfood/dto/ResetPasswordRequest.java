package com.foomyfood.foomyfood.dto;

public class ResetPasswordRequest {
    private String email;  // 添加 email 字段以便查找用户
    private String newPassword;

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getNewPassword() {
        return newPassword;
    }

    public void setNewPassword(String newPassword) {
        this.newPassword = newPassword;
    }
}
