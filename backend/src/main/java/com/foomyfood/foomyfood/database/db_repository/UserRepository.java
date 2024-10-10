package com.foomyfood.foomyfood.database.db_repository;

import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.foomyfood.foomyfood.database.User;

@Repository
public interface UserRepository extends JpaRepository<User, Long> {

    Optional<User> findByUserName(String userName);

    Optional<User> findByEmailAddress(String emailAddress);

    Optional<User> findByPhoneNumber(String phoneNumber);

    Optional<User> findByEmailVerificationToken(String emailVerificationToken);
}
