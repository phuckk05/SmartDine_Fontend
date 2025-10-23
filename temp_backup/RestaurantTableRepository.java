package com.smartdine.repository;

import com.smartdine.models.RestaurantTable;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface RestaurantTableRepository extends JpaRepository<RestaurantTable, Integer> {
    List<RestaurantTable> findByBranchId(Integer branchId);
    List<RestaurantTable> findByStatusId(Integer statusId);
    List<RestaurantTable> findByTypeId(Integer typeId);
    List<RestaurantTable> findByBranchIdAndStatusId(Integer branchId, Integer statusId);
    Long countByBranchId(Integer branchId);
}