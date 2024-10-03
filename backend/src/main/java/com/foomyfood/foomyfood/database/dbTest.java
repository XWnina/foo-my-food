package com.foomyfood.foomyfood.database;

import java.util.Scanner;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;

import com.foomyfood.foomyfood.database.service.UserService;

@Component
public class dbTest implements CommandLineRunner {

    @Autowired
    private UserService userService;

    @Override
    public void run(String... args) throws Exception {
        Scanner scanner = new Scanner(System.in);
        String continueInput;

        do {
            // 提供选择：创建用户、删除用户、查找用户ID 或更新用户信息
            System.out.println("请选择操作: 1. 创建用户  2. 删除用户  3. 通过用户名查找用户ID  4. 更新用户信息");
            String action = scanner.nextLine();

            if ("1".equals(action)) {
                // 创建用户流程（代码保持不变）
                // ...
            } else if ("2".equals(action)) {
                // 删除用户流程（代码保持不变）
                // ...
            } else if ("3".equals(action)) {
                // 查找用户ID流程（代码保持不变）
                // ...
            } else if ("4".equals(action)) {
                // 更新用户信息
                System.out.println("请输入要更新的用户ID:");
                Long userId = Long.parseLong(scanner.nextLine());

                // 提示输入新的用户信息
                System.out.println("请输入新的 firstName:");
                String firstName = scanner.nextLine();

                System.out.println("请输入新的 lastName:");
                String lastName = scanner.nextLine();

                System.out.println("请输入新的 userName:");
                String userName = scanner.nextLine();

                System.out.println("请输入新的 emailAddress:");
                String emailAddress = scanner.nextLine();

                System.out.println("请输入新的 phoneNumber:");
                String phoneNumber = scanner.nextLine();

                System.out.println("请输入新的 password:");
                String password = scanner.nextLine();

                System.out.println("请输入新的 imageURL:");
                String imageURL = scanner.nextLine();

                System.out.println("请输入新的 emailVerificationToken:");
                String emailVerificationToken = scanner.nextLine();

                System.out.println("用户是否验证邮箱 (true/false):");
                Boolean emailVerified = Boolean.parseBoolean(scanner.nextLine());

                // 调用服务更新用户信息
                User updatedUser = userService.updateUser(
                    userId,
                    firstName,
                    lastName,
                    userName,
                    emailAddress,
                    phoneNumber,
                    password,
                    imageURL,
                    emailVerificationToken,
                    emailVerified
                );

                System.out.println("用户已成功更新，ID: " + updatedUser.getId());

            } else {
                System.out.println("无效的操作，请选择 1, 2, 3 或 4.");
            }

            // 询问用户是否继续操作
            System.out.println("是否继续操作？ (yes/no)");
            continueInput = scanner.nextLine();

        } while (continueInput.equalsIgnoreCase("yes"));

        System.out.println("结束用户数据操作.");
        scanner.close();
    }
}
