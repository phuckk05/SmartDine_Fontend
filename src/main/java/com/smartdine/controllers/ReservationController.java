package com.smartdine.controllers;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.time.ZoneId;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.stream.Collectors;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.smartdine.models.Reservation;
import com.smartdine.models.ReservationTable;
import com.smartdine.models.idclass.ReservationTableId;
import com.smartdine.services.ReservationServices;
import com.smartdine.services.ReservationTableServices;

@RestController
@RequestMapping("/api/reservations")
public class ReservationController {

    @Autowired
    ReservationServices reservationServices;

    @Autowired
    ReservationTableServices reservationTableServices;

    // Tạo reservation mới với danh sách table
    @PostMapping
    public ResponseEntity<?> createReservation(@RequestBody Map<String, Object> request) {
        try {
            // Parse reservation data
            Map<String, Object> reservationData = (Map<String, Object>) request.get("reservation");
            List<Integer> tableIds = (List<Integer>) request.get("tableIds");

            if (reservationData == null || tableIds == null || tableIds.isEmpty()) {
                return ResponseEntity.badRequest().body("Reservation data and tableIds are required");
            }

            // Create reservation object
            Reservation reservation = new Reservation();
            reservation.setBranchId((Integer) reservationData.get("branchId"));
            reservation.setCustomerName((String) reservationData.get("customerName"));
            reservation.setCustomerEmail((String) reservationData.get("customerEmail"));
            reservation.setReservedTime(parseDateTime((String) reservationData.get("reservedTime")));
            reservation.setNumberOfGuests((Integer) reservationData.get("numberOfGuests"));
            reservation.setReservedDay(parseDateTime((String) reservationData.get("reservedDay")));
            reservation.setStatusId((Integer) reservationData.get("statusId"));
            reservation.setNote((String) reservationData.get("note"));

            // Save reservation
            Reservation savedReservation = reservationServices.saveReservation(reservation);

            // Create reservation-table relationships
            List<ReservationTable> reservationTables = tableIds.stream()
                    .map(tableId -> new ReservationTable(savedReservation.getId(), tableId))
                    .collect(Collectors.toList());

            reservationTableServices.saveReservationTables(reservationTables);

            // Return response with reservation and assigned tables
            Map<String, Object> response = new HashMap<>();
            response.put("reservation", savedReservation);
            response.put("tableIds", tableIds);

            return ResponseEntity.ok(response);

        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.internalServerError().body("Error creating reservation: " + e.getMessage());
        }
    }

    // Lấy tất cả reservation
    @GetMapping
    public List<Reservation> getAllReservations() {
        return reservationServices.getAllReservations();
    }

    // Lấy reservation theo id với danh sách table
    @GetMapping("/{id}")
    public ResponseEntity<?> getReservationById(@PathVariable Integer id) {
        Optional<Reservation> reservation = reservationServices.getReservationById(id);
        if (reservation.isPresent()) {
            List<ReservationTable> reservationTables = reservationTableServices.getReservationTablesByReservationId(id);
            List<Integer> tableIds = reservationTables.stream()
                    .map(ReservationTable::getTableId)
                    .collect(Collectors.toList());

            Map<String, Object> response = new HashMap<>();
            response.put("reservation", reservation.get());
            response.put("tableIds", tableIds);

            return ResponseEntity.ok(response);
        }
        return ResponseEntity.notFound().build();
    }

    // Lấy danh sách reservation theo branchId
    @GetMapping("/branch/{branchId}")
    public List<Reservation> getReservationsByBranchId(@PathVariable Integer branchId) {
        return reservationServices.getReservationsByBranchId(branchId);
    }

    // Lấy danh sách reservation theo branchId và statusId
    @GetMapping("/branch/{branchId}/status/{statusId}")
    public List<Reservation> getReservationsByBranchIdAndStatusId(
            @PathVariable Integer branchId,
            @PathVariable Integer statusId) {
        return reservationServices.getReservationsByBranchIdAndStatusId(branchId, statusId);
    }

    // Lấy danh sách reservation theo ngày
    @GetMapping("/date")
    public List<Reservation> getReservationsByDate(@RequestParam String date) {
        LocalDateTime dateTime = parseDateTime(date);
        return reservationServices.getReservationsByDate(dateTime);
    }

    // Lấy danh sách reservation theo branchId và ngày
    @GetMapping("/branch/{branchId}/date")
    public List<Reservation> getReservationsByBranchIdAndDate(
            @PathVariable Integer branchId,
            @RequestParam String date) {
        LocalDateTime dateTime = parseDateTime(date);
        return reservationServices.getReservationsByBranchIdAndDate(branchId, dateTime);
    }

    // Lấy danh sách reservation hôm nay theo branchId
    @GetMapping("/branch/{branchId}/today")
    public List<Reservation> getTodayReservationsByBranchId(@PathVariable Integer branchId) {
        return reservationServices.getTodayReservationsByBranchId(branchId);
    }

    // Cập nhật reservation
    @PutMapping("/{id}")
    public ResponseEntity<?> updateReservation(@PathVariable Integer id, @RequestBody Map<String, Object> request) {
        try {
            Optional<Reservation> existingReservation = reservationServices.getReservationById(id);
            if (!existingReservation.isPresent()) {
                return ResponseEntity.notFound().build();
            }

            // Parse request data
            Map<String, Object> reservationData = (Map<String, Object>) request.get("reservation");
            List<Integer> tableIds = (List<Integer>) request.get("tableIds");

            // Update reservation
            Reservation reservation = existingReservation.get();
            if (reservationData.containsKey("branchId")) {
                reservation.setBranchId((Integer) reservationData.get("branchId"));
            }
            if (reservationData.containsKey("customerName")) {
                reservation.setCustomerName((String) reservationData.get("customerName"));
            }
            if (reservationData.containsKey("customerEmail")) {
                reservation.setCustomerEmail((String) reservationData.get("customerEmail"));
            }
            if (reservationData.containsKey("reservedTime")) {
                reservation.setReservedTime(parseDateTime((String) reservationData.get("reservedTime")));
            }
            if (reservationData.containsKey("numberOfGuests")) {
                reservation.setNumberOfGuests((Integer) reservationData.get("numberOfGuests"));
            }
            if (reservationData.containsKey("reservedDay")) {
                reservation.setReservedDay(parseDateTime((String) reservationData.get("reservedDay")));
            }
            if (reservationData.containsKey("statusId")) {
                reservation.setStatusId((Integer) reservationData.get("statusId"));
            }
            if (reservationData.containsKey("note")) {
                reservation.setNote((String) reservationData.get("note"));
            }

            Reservation updatedReservation = reservationServices.saveReservation(reservation);

            // Update table assignments if provided
            if (tableIds != null) {
                // Delete existing assignments
                reservationTableServices.deleteReservationTablesByReservationId(id);

                // Create new assignments
                List<ReservationTable> reservationTables = tableIds.stream()
                        .map(tableId -> new ReservationTable(id, tableId))
                        .collect(Collectors.toList());

                reservationTableServices.saveReservationTables(reservationTables);
            }

            // Get current table assignments
            List<ReservationTable> currentTables = reservationTableServices.getReservationTablesByReservationId(id);
            List<Integer> currentTableIds = currentTables.stream()
                    .map(ReservationTable::getTableId)
                    .collect(Collectors.toList());

            Map<String, Object> response = new HashMap<>();
            response.put("reservation", updatedReservation);
            response.put("tableIds", currentTableIds);

            return ResponseEntity.ok(response);

        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.internalServerError().body("Error updating reservation: " + e.getMessage());
        }
    }

    // Cập nhật trạng thái reservation
    @PutMapping("/{id}/status")
    public ResponseEntity<?> updateReservationStatus(@PathVariable Integer id,
            @RequestBody Map<String, Integer> request) {
        try {
            Integer statusId = request.get("statusId");
            if (statusId == null) {
                return ResponseEntity.badRequest().body("statusId is required");
            }

            Optional<Reservation> reservation = reservationServices.getReservationById(id);
            if (!reservation.isPresent()) {
                return ResponseEntity.notFound().build();
            }

            reservation.get().setStatusId(statusId);
            Reservation updatedReservation = reservationServices.saveReservation(reservation.get());

            return ResponseEntity.ok(updatedReservation);

        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.internalServerError().body("Error updating reservation status: " + e.getMessage());
        }
    }

    // Xóa reservation
    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteReservation(@PathVariable Integer id) {
        try {
            if (!reservationServices.existsById(id)) {
                return ResponseEntity.notFound().build();
            }

            // Delete table assignments first
            reservationTableServices.deleteReservationTablesByReservationId(id);

            // Delete reservation
            reservationServices.deleteReservation(id);

            return ResponseEntity.ok("Reservation deleted successfully");

        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.internalServerError().body("Error deleting reservation: " + e.getMessage());
        }
    }

    // Lấy danh sách table được assign cho reservation
    @GetMapping("/{id}/tables")
    public List<Integer> getReservationTables(@PathVariable Integer id) {
        List<ReservationTable> reservationTables = reservationTableServices.getReservationTablesByReservationId(id);
        return reservationTables.stream()
                .map(ReservationTable::getTableId)
                .collect(Collectors.toList());
    }

    // Lấy danh sách ID bàn đã đặt với trạng thái theo thời gian
    @GetMapping("/reserved-tables")
    public ResponseEntity<?> getReservedTableIds() {
        try {
            List<ReservationTable> allReservationTables = reservationTableServices.getAllReservationTables();
            LocalDateTime now = LocalDateTime.now(ZoneId.of("Asia/Ho_Chi_Minh"));

            Map<String, Object> result = new HashMap<>();
            List<Integer> availableTables = new ArrayList<>(); // Có thể hủy đặt (< 2 tiếng)
            List<Integer> reservedTables = new ArrayList<>(); // Đã đặt (>= 2 tiếng)

            for (ReservationTable rt : allReservationTables) {
                Optional<Reservation> reservationOpt = reservationServices.getReservationById(rt.getReservationId());
                if (reservationOpt.isPresent()) {
                    Reservation reservation = reservationOpt.get();
                    LocalDateTime reservedTime = reservation.getReservedTime();

                    if (reservedTime != null) {
                        // Tính khoảng thời gian giữa hiện tại và thời gian đặt
                        long hoursDifference = java.time.Duration.between(now, reservedTime).toHours();

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
            result.put("totalReserved", availableTables.size() + reservedTables.size());

            return ResponseEntity.ok(result);

        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.internalServerError().body("Error getting reserved table IDs: " + e.getMessage());
        }
    }

    // Lấy danh sách ID bàn đã đặt theo chi nhánh với trạng thái theo thời gian
    @GetMapping("/reserved-tables/branch/{branchId}")
    public ResponseEntity<?> getReservedTableIdsByBranch(@PathVariable Integer branchId) {
        try {
            List<Reservation> branchReservations = reservationServices.getReservationsByBranchId(branchId);
            LocalDateTime now = LocalDateTime.now(ZoneId.of("Asia/Ho_Chi_Minh"));

            Map<String, Object> result = new HashMap<>();
            List<Integer> availableTables = new ArrayList<>(); // Có thể hủy đặt (< 2 tiếng)
            List<Integer> reservedTables = new ArrayList<>(); // Đã đặt (>= 2 tiếng)

            for (Reservation reservation : branchReservations) {
                List<ReservationTable> reservationTables = reservationTableServices
                        .getReservationTablesByReservationId(reservation.getId());
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

            result.put("branchId", branchId);
            result.put("availableTables", availableTables); // Có thể hủy đặt (< 2 tiếng)
            result.put("reservedTables", reservedTables); // Đã đặt (>= 2 tiếng)
            result.put("currentTime", now.toString());
            result.put("totalReserved", availableTables.size() + reservedTables.size());

            return ResponseEntity.ok(result);

        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.internalServerError()
                    .body("Error getting reserved table IDs by branch: " + e.getMessage());
        }
    }

    // Thêm table vào reservation
    @PostMapping("/{reservationId}/tables/{tableId}")
    public ResponseEntity<?> addTableToReservation(
            @PathVariable Integer reservationId,
            @PathVariable Integer tableId) {
        try {
            if (!reservationServices.existsById(reservationId)) {
                return ResponseEntity.status(HttpStatus.NOT_FOUND).body("Reservation not found");
            }

            ReservationTableId id = new ReservationTableId(reservationId, tableId);
            if (reservationTableServices.existsById(id)) {
                return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("Table already assigned to this reservation");
            }

            ReservationTable reservationTable = new ReservationTable(reservationId, tableId);
            reservationTableServices.saveReservationTable(reservationTable);

            return ResponseEntity.ok("Table added to reservation successfully");

        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.internalServerError().body("Error adding table to reservation: " + e.getMessage());
        }
    }

    // Xóa table khỏi reservation
    @DeleteMapping("/{reservationId}/tables/{tableId}")
    public ResponseEntity<?> removeTableFromReservation(
            @PathVariable Integer reservationId,
            @PathVariable Integer tableId) {
        try {
            ReservationTableId id = new ReservationTableId(reservationId, tableId);
            if (!reservationTableServices.existsById(id)) {
                return ResponseEntity.status(HttpStatus.NOT_FOUND).body("Table assignment not found");
            }

            reservationTableServices.deleteReservationTable(id);

            return ResponseEntity.ok("Table removed from reservation successfully");

        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.internalServerError()
                    .body("Error removing table from reservation: " + e.getMessage());
        }
    }

    // Helper method to parse date time string
    private LocalDateTime parseDateTime(String dateTimeString) {
        if (dateTimeString == null || dateTimeString.isEmpty()) {
            return null;
        }
        try {
            // Try ISO format first
            return LocalDateTime.parse(dateTimeString);
        } catch (Exception e) {
            try {
                // Try custom format
                DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");
                return LocalDateTime.parse(dateTimeString, formatter);
            } catch (Exception e2) {
                // Return current time as fallback
                return LocalDateTime.now();
            }
        }
    }
}