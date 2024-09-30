package com.foomyfood.foomyfood.database.controller;


import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

import com.foomyfood.foomyfood.database.Vegetable;
import com.foomyfood.foomyfood.database.service.VegetableService;

@RestController
public class VegetableController {

    @Autowired
    private VegetableService vegetableService;

    @PostMapping("/vegetable creation")
    public Vegetable createVegetable(@RequestBody Vegetable vegetable) {
        return vegetableService.createVegetable(vegetable.getName(), vegetable.getCategory(), vegetable.getShelfLife(), vegetable.getStorageType());
    }
}

