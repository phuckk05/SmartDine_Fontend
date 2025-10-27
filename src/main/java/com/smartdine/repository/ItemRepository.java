package com.smartdine.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;

import com.smartdine.models.Item;

public interface ItemRepository extends JpaRepository<Item, Integer> {
    //Lay items comapanyId & statusId
    public List<Item> getByCompanyId(Integer companyId);
}
