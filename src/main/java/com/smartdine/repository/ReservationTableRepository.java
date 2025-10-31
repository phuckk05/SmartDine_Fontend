package com.smartdine.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.transaction.annotation.Transactional;

import com.smartdine.models.ReservationTable;
import com.smartdine.models.idclass.ReservationTableId;

public interface ReservationTableRepository extends JpaRepository<ReservationTable, ReservationTableId> {

    // Lấy danh sách table theo reservationId
    List<ReservationTable> findByReservationId(Integer reservationId);

    // Lấy danh sách reservation theo tableId
    List<ReservationTable> findByTableId(Integer tableId);

    // Xóa tất cả ReservationTable theo reservationId
    @Modifying
    @Transactional
    @Query("DELETE FROM ReservationTable rt WHERE rt.reservationId = :reservationId")
    void deleteByReservationId(@Param("reservationId") Integer reservationId);

    // Xóa tất cả ReservationTable theo tableId
    @Modifying
    @Transactional
    @Query("DELETE FROM ReservationTable rt WHERE rt.tableId = :tableId")
    void deleteByTableId(@Param("tableId") Integer tableId);

    // Kiểm tra xem table có được đặt chưa trong reservation
    @Query("SELECT COUNT(rt) > 0 FROM ReservationTable rt WHERE rt.tableId = :tableId")
    boolean existsByTableId(@Param("tableId") Integer tableId);
}