package com.foomyfood.foomyfood.database.repository;

import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.foomyfood.foomyfood.database.User;

@Repository
public interface UserRepository extends JpaRepository<User, Long> {
    
    // find the user id via unique username
    Optional<User> findByUserName(String userName);
}
