package com.smartdine.repository;

import java.time.LocalDateTime;
import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import com.smartdine.models.Reservation;

public interface ReservationRepository extends JpaRepository<Reservation, Integer> {

    // Lấy danh sách reservation theo branchId
    List<Reservation> findByBranchId(Integer branchId);

    // Lấy danh sách reservation theo customerEmail
    List<Reservation> findByCustomerEmail(String customerEmail);

    // Lấy danh sách reservation theo statusId
    List<Reservation> findByStatusId(Integer statusId);

    // Lấy danh sách reservation theo branchId và statusId
    List<Reservation> findByBranchIdAndStatusId(Integer branchId, Integer statusId);

    // Lấy danh sách reservation trong khoảng thời gian
    List<Reservation> findByReservedDayBetween(LocalDateTime startDate, LocalDateTime endDate);

    // Lấy danh sách reservation theo branchId trong khoảng thời gian
    List<Reservation> findByBranchIdAndReservedDayBetween(Integer branchId, LocalDateTime startDate,
            LocalDateTime endDate);

    // Lấy danh sách reservation theo ngày cụ thể
    @Query("SELECT r FROM Reservation r WHERE DATE(r.reservedDay) = DATE(:date)")
    List<Reservation> findByReservedDay(@Param("date") LocalDateTime date);

    // Lấy danh sách reservation theo branchId và ngày cụ thể
    @Query("SELECT r FROM Reservation r WHERE r.branchId = :branchId AND DATE(r.reservedDay) = DATE(:date)")
    List<Reservation> findByBranchIdAndReservedDay(@Param("branchId") Integer branchId,
            @Param("date") LocalDateTime date);

    // Lấy danh sách reservation theo branchId, ngày cụ thể và statusId
    @Query("SELECT r FROM Reservation r WHERE r.branchId = :branchId AND DATE(r.reservedDay) = DATE(:date) AND r.statusId = :statusId")
    List<Reservation> findByBranchIdAndReservedDayAndStatusId(@Param("branchId") Integer branchId,
            @Param("date") LocalDateTime date, @Param("statusId") Integer statusId);
}