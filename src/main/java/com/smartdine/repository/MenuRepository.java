package com.smartdine.repository;

import org.springframework.data.jpa.repository.JpaRepository;

import com.smartdine.models.Menu;
import java.util.List;

public interface MenuRepository extends JpaRepository<Menu, Integer> {
    //Lay menu theo company id
    List<Menu> findByCompanyId(Integer companyId);
}
