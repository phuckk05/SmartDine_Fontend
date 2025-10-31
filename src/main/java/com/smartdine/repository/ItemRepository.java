package com.smartdine.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;

import com.smartdine.models.Item;

public interface ItemRepository extends JpaRepository<Item, Integer> {
    // Lấy items theo companyId
    List<Item> findByCompanyId(Integer companyId);

    List<Item> getByCompanyId(Integer companyId);
}
