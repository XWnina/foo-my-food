package com.foomyfood.foomyfood.database.repository;

import com.foomyfood.foomyfood.database.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface UserRepository extends JpaRepository<User, Long> {

    Optional<User> findByUserName(String userName);

    Optional<User> findByEmailAddress(String emailAddress);

    Optional<User> findByPhoneNumber(String phoneNumber);

    // 根据 emailVerificationToken 查找用户
    Optional<User> findByEmailVerificationToken(String emailVerificationToken);
}
