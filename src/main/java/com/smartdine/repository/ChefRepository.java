package com.smartdine.repositories;

import org.springframework.data.jpa.repository.JpaRepository;
import com.smartdine.models.Chef;

public interface ChefRepository extends JpaRepository<Chef, Integer> { }
