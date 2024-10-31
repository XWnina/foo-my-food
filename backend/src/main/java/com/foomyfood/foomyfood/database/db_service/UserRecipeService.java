package com.foomyfood.foomyfood.database.db_service;

import java.util.List;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.foomyfood.foomyfood.database.UserRecipe;
import com.foomyfood.foomyfood.database.db_repository.UserRecipeRepository;

@Service
public class UserRecipeService {

    private final UserRecipeRepository userRecipeRepository;

    @Autowired
    public UserRecipeService(UserRecipeRepository userRecipeRepository) {
        this.userRecipeRepository = userRecipeRepository;
    }

    // Create or Save a new UserRecipe
    public UserRecipe createUserRecipe(UserRecipe userRecipe) {
        return userRecipeRepository.save(userRecipe);
    }

    // Delete a UserRecipe by ID
    public void deleteUserRecipe(Long id) {
        userRecipeRepository.deleteById(id);
    }

    // Update an existing UserRecipe
    public UserRecipe updateUserRecipe(Long id, UserRecipe updatedUserRecipe) {
        Optional<UserRecipe> existingUserRecipe = userRecipeRepository.findById(id);
        if (existingUserRecipe.isPresent()) {
            UserRecipe userRecipe = existingUserRecipe.get();
            userRecipe.setUserId(updatedUserRecipe.getUserId());
            userRecipe.setRecipeId(updatedUserRecipe.getRecipeId());
            userRecipe.setUserCookedTimes(updatedUserRecipe.getUserCookedTimes());
            return userRecipeRepository.save(userRecipe);
        }
        return null;
    }

    // Adding one time in userCookedTimes
    public UserRecipe addOneTime(Long recipe_id) {
        Optional<UserRecipe> existingUserRecipe = userRecipeRepository.findById(recipe_id);
        if (existingUserRecipe.isPresent()) {
            UserRecipe userRecipe = existingUserRecipe.get();
            userRecipe.setUserCookedTimes(userRecipe.getUserCookedTimes() + 1);
            return userRecipeRepository.save(userRecipe);
        }
        return null;
    }

    public Optional<UserRecipe> getUserRecipeById(Long user_id) {
        return userRecipeRepository.findById(user_id);
    }
    
    public List<UserRecipe> getAllUserRecipes() {
        return userRecipeRepository.findAll();
    }
    
}
