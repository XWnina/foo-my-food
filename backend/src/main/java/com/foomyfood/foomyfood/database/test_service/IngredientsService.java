package com.foomyfood.foomyfood.database.test_service;


import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.foomyfood.foomyfood.database.Ingredients;
import com.foomyfood.foomyfood.database.repository.IngredientsRepository;

@Service
public class IngredientsService {

    @Autowired
    private IngredientsRepository IngredientsRepository;

    public Ingredients createIngredients(String name, String category, String shelfLife, String storageType) {
        Ingredients item = new Ingredients(name, category, shelfLife, storageType);
        return IngredientsRepository.save(item);
    }
}
