package com.smartdine.services;

import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import com.smartdine.models.Chef;
import com.smartdine.repositories.ChefRepository;

@Service
public class ChefService {

    @Autowired
    private ChefRepository chefRepository;

    public List<Chef> getAll() {
        return chefRepository.findAll();
    }

    public Chef getById(Integer id) {
        return chefRepository.findById(id).orElse(null);
    }
}
