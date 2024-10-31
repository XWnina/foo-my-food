package com.foomyfood.foomyfood.database.db_controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.foomyfood.foomyfood.database.UserRecipe;
import com.foomyfood.foomyfood.database.db_service.UserRecipeService;

@RestController
@RequestMapping("/api/user-recipes")
public class UserRecipeController {

    private final UserRecipeService userRecipeService;

    @Autowired
    public UserRecipeController(UserRecipeService userRecipeService) {
        this.userRecipeService = userRecipeService;
    }

    // Create a new UserRecipe
    @PostMapping
    public ResponseEntity<UserRecipe> createUserRecipe(@RequestBody UserRecipe userRecipe) {
        UserRecipe createdUserRecipe = userRecipeService.createUserRecipe(userRecipe);
        return new ResponseEntity<>(createdUserRecipe, HttpStatus.CREATED);
    }

    // Delete a UserRecipe by ID
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteUserRecipe(@PathVariable Long id) {
        userRecipeService.deleteUserRecipe(id);
        return new ResponseEntity<>(HttpStatus.NO_CONTENT);
    }

    // Update an existing UserRecipe
    @PutMapping("/{id}")
    public ResponseEntity<UserRecipe> updateUserRecipe(
            @PathVariable Long id, @RequestBody UserRecipe userRecipe) {
        UserRecipe updatedUserRecipe = userRecipeService.updateUserRecipe(id, userRecipe);
        if (updatedUserRecipe != null) {
            return new ResponseEntity<>(updatedUserRecipe, HttpStatus.OK);
        } else {
            return new ResponseEntity<>(HttpStatus.NOT_FOUND);
        }
    }

    // Add one time in userCookedTimes
    @PutMapping("/add-one-time/{recipe_id}")
    public ResponseEntity<UserRecipe> addOneTime(@PathVariable Long recipe_id) {
        UserRecipe updatedUserRecipe = userRecipeService.addOneTime(recipe_id);
        if (updatedUserRecipe != null) {
            return new ResponseEntity<>(updatedUserRecipe, HttpStatus.OK);
        } else {
            return new ResponseEntity<>(HttpStatus.NOT_FOUND);
        }
    }
}
