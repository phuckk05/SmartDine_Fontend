package com.smartdine.services;

import java.time.LocalDateTime;
import java.time.ZoneId;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.smartdine.models.Reservation;
import com.smartdine.models.ReservationTable;
import com.smartdine.repository.ReservationRepository;
import com.smartdine.repository.ReservationTableRepository;

@Service
public class ReservationServices {

    @Autowired
    ReservationRepository reservationRepository;

    @Autowired
    ReservationTableRepository reservationTableRepository;

    // Lưu reservation
    public Reservation saveReservation(Reservation reservation) {
        return reservationRepository.save(reservation);
    }

    // Lấy tất cả reservation
    public List<Reservation> getAllReservations() {
        return reservationRepository.findAll();
    }

    // Lấy reservation theo id
    public Optional<Reservation> getReservationById(Integer id) {
        return reservationRepository.findById(id);
    }

    // Lấy danh sách reservation theo branchId
    public List<Reservation> getReservationsByBranchId(Integer branchId) {
        return reservationRepository.findByBranchId(branchId);
    }

    // Lấy danh sách reservation theo customerEmail
    public List<Reservation> getReservationsByCustomerEmail(String customerEmail) {
        return reservationRepository.findByCustomerEmail(customerEmail);
    }

    // Lấy danh sách reservation theo statusId
    public List<Reservation> getReservationsByStatusId(Integer statusId) {
        return reservationRepository.findByStatusId(statusId);
    }

    // Lấy danh sách reservation theo branchId và statusId
    public List<Reservation> getReservationsByBranchIdAndStatusId(Integer branchId, Integer statusId) {
        return reservationRepository.findByBranchIdAndStatusId(branchId, statusId);
    }

    // Lấy danh sách reservation trong khoảng thời gian
    public List<Reservation> getReservationsByDateRange(LocalDateTime startDate, LocalDateTime endDate) {
        return reservationRepository.findByReservedDayBetween(startDate, endDate);
    }

    // Lấy danh sách reservation theo branchId trong khoảng thời gian
    public List<Reservation> getReservationsByBranchIdAndDateRange(Integer branchId, LocalDateTime startDate,
            LocalDateTime endDate) {
        return reservationRepository.findByBranchIdAndReservedDayBetween(branchId, startDate, endDate);
    }

    // Lấy danh sách reservation theo ngày cụ thể
    public List<Reservation> getReservationsByDate(LocalDateTime date) {
        return reservationRepository.findByReservedDay(date);
    }

    // Lấy danh sách reservation theo branchId và ngày cụ thể
    public List<Reservation> getReservationsByBranchIdAndDate(Integer branchId, LocalDateTime date) {
        return reservationRepository.findByBranchIdAndReservedDay(branchId, date);
    }

    // Lấy danh sách reservation theo branchId, ngày cụ thể và statusId
    public List<Reservation> getReservationsByBranchIdAndDateAndStatusId(Integer branchId, LocalDateTime date,
            Integer statusId) {
        return reservationRepository.findByBranchIdAndReservedDayAndStatusId(branchId, date, statusId);
    }

    // Lấy danh sách reservation hôm nay theo branchId
    public List<Reservation> getTodayReservationsByBranchId(Integer branchId) {
        LocalDateTime now = LocalDateTime.now(ZoneId.of("Asia/Ho_Chi_Minh"));
        LocalDateTime startOfDay = now.withHour(0).withMinute(0).withSecond(0).withNano(0);
        return reservationRepository.findByBranchIdAndReservedDay(branchId, startOfDay);
    }

    // Xóa reservation theo id
    public void deleteReservation(Integer id) {
        reservationRepository.deleteById(id);
    }

    // Kiểm tra reservation có tồn tại không
    public boolean existsById(Integer id) {
        return reservationRepository.existsById(id);
    }

    // Lấy danh sách ID bàn đã đặt theo chi nhánh với trạng thái theo thời gian
    public Map<String, Object> getReservedTableIdsByBranch(Integer branchId) {
        List<Reservation> branchReservations = reservationRepository.findByBranchId(branchId);
        LocalDateTime now = LocalDateTime.now(ZoneId.of("Asia/Ho_Chi_Minh"));

        Map<String, Object> result = new HashMap<>();
        List<Integer> availableTables = new ArrayList<>(); // Có thể hủy đặt (< 2 tiếng)
        List<Integer> reservedTables = new ArrayList<>(); // Đã đặt (>= 2 tiếng)

        for (Reservation reservation : branchReservations) {
            List<ReservationTable> reservationTables = reservationTableRepository
                    .findByReservationId(reservation.getId());
            LocalDateTime reservedTime = reservation.getReservedTime();

            if (reservedTime != null) {
                // Tính khoảng thời gian giữa hiện tại và thời gian đặt
                long hoursDifference = java.time.Duration.between(now, reservedTime).toHours();

                for (ReservationTable rt : reservationTables) {
                    if (hoursDifference < 2) {
                        // Dưới 2 tiếng - có thể hủy đặt (bàn trống)
                        if (!availableTables.contains(rt.getTableId())) {
                            availableTables.add(rt.getTableId());
                        }
                    } else {
                        // Từ 2 tiếng trở lên - đã đặt (không thể hủy)
                        if (!reservedTables.contains(rt.getTableId())) {
                            reservedTables.add(rt.getTableId());
                        }
                    }
                }
            }
        }

        result.put("availableTables", availableTables); // Có thể hủy đặt (< 2 tiếng)
        result.put("reservedTables", reservedTables); // Đã đặt (>= 2 tiếng)
        result.put("currentTime", now.toString());

        return result;
    }
}