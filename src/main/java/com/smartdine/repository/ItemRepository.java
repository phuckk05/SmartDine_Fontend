package com.smartdine.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import com.smartdine.models.Item;

public interface ItemRepository extends JpaRepository<Item, Integer> {
    // Lấy items theo companyId
    List<Item> findByCompanyId(Integer companyId);

    // Lấy items theo companyId và categoryId thông qua bảng menu_items
    @Query(value = "SELECT i.* FROM items i JOIN menu_items mi ON mi.item_id = i.id "
            + "WHERE i.company_id = :companyId AND mi.category_id = :categoryId", nativeQuery = true)
    List<Item> findByCompanyIdAndCategoryId(@Param("companyId") Integer companyId,
            @Param("categoryId") Integer categoryId);
}
