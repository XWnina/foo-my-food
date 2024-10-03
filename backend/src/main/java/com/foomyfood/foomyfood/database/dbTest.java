package com.foomyfood.foomyfood.database;

import java.util.Optional;
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
            // 提供选择：创建用户、删除用户或查找用户ID
            System.out.println("请选择操作: 1. 创建用户  2. 删除用户  3. 通过用户名查找用户ID  4. 更新用户信息");
            String action = scanner.nextLine();

            if ("1".equals(action)) {
                // 创建用户流程
                System.out.println("请输入用户的 firstName:");
                String firstName = scanner.nextLine();

                System.out.println("请输入用户的 lastName:");
                String lastName = scanner.nextLine();

                System.out.println("请输入用户的 userName:");
                String userName = scanner.nextLine();

                System.out.println("请输入用户的 emailAddress:");
                String emailAddress = scanner.nextLine();

                System.out.println("请输入用户的 phoneNumber:");
                String phoneNumber = scanner.nextLine();

                System.out.println("请输入用户的 password:");
                String password = scanner.nextLine();

                System.out.println("请输入用户的 imageURL:");
                String imageURL = scanner.nextLine();

                System.out.println("请输入用户的 emailVerificationToken:");
                String emailVerificationToken = scanner.nextLine();

                System.out.println("用户是否验证邮箱 (true/false):");
                Boolean emailVerified = Boolean.parseBoolean(scanner.nextLine());

                // 创建并保存用户
                User testUser = new User(
                        firstName, // firstName
                        lastName, // lastName
                        userName, // userName
                        emailAddress, // emailAddress
                        phoneNumber, // phoneNumber
                        password, // password
                        imageURL, // imageURL
                        emailVerificationToken, // emailVerificationToken
                        emailVerified // emailVerified
                );

                User savedUser = userService.createUser(
                        testUser.getFirstName(),
                        testUser.getLastName(),
                        testUser.getUserName(),
                        testUser.getEmailAddress(),
                        testUser.getPhoneNumber(),
                        testUser.getPassword(),
                        testUser.getImageURL(),
                        testUser.getEmailVerificationToken(),
                        testUser.getEmailVerified()
                );

                System.out.println("用户已成功保存，ID: " + savedUser.getId());

            } else if ("2".equals(action)) {
                // 删除用户流程
                System.out.println("请输入要删除的用户 ID:");
                Long userId = Long.parseLong(scanner.nextLine());

                // 删除用户
                userService.deleteUser(userId);

                System.out.println("用户已成功删除，ID: " + userId);

            } else if ("3".equals(action)) {
                // 根据用户名查找用户ID
                System.out.println("请输入用户名:");
                String userName = scanner.nextLine();

                Optional<User> user = userService.getUserByUserName(userName);

                if (user.isPresent()) {
                    System.out.println("找到的用户ID: " + user.get().getId());
                } else {
                    System.out.println("未找到该用户名对应的用户.");
                }

            } else if ("4".equals(action)) {
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

                System.out.println("用户已成功更新, ID: " + updatedUser.getId());

            } else {
                System.out.println("无效的操作，请选择 1, 2, 3或4.");
            }

            // 询问用户是否继续操作
            System.out.println("是否继续操作？ (yes/no)");
            continueInput = scanner.nextLine();

        } while (continueInput.equalsIgnoreCase("yes"));

        System.out.println("结束用户数据操作.");
        scanner.close();
    }
}
