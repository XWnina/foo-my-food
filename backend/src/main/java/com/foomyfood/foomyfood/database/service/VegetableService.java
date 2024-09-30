package com.foomyfood.foomyfood.database.service;


import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.foomyfood.foomyfood.database.Vegetable;
import com.foomyfood.foomyfood.database.repository.VegetableRepository;

@Service
public class VegetableService {

    @Autowired
    private VegetableRepository vegetableRepository;

    public Vegetable createVegetable(String name, String category, String shelfLife, String storageType) {
        Vegetable item = new Vegetable(name, category, shelfLife, storageType);
        return vegetableRepository.save(item);
    }
}
