package com.smartdine.repository;

import org.springframework.data.jpa.repository.JpaRepository;

import com.smartdine.models.status.ReservationStatus;

public interface ReservationStatusRepository extends JpaRepository<ReservationStatus, Integer> {
}
