package com.smartdine.repository;

import org.springframework.data.jpa.repository.JpaRepository;

import com.smartdine.models.OrderItemAction;

public interface OrderItemActionRepository extends JpaRepository<OrderItemAction, Integer> {
}
