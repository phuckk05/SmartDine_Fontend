package com.smartdine.repository;

import org.springframework.data.jpa.repository.JpaRepository;

import com.smartdine.models.ReservationStatus;

public interface ReservationStatusRepository extends JpaRepository<ReservationStatus, Integer> {
}
