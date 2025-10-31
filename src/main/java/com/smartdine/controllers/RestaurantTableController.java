package com.smartdine.controllers;

import java.time.LocalDateTime;
import java.time.ZoneId;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.smartdine.models.RestaurantTable;
import com.smartdine.services.OrderServices;
import com.smartdine.services.RestaurantTableServices;
import com.smartdine.services.ReservationServices;

@RestController
@RequestMapping("/api/tables")
public class RestaurantTableController {

    @Autowired
    private RestaurantTableServices restaurantTableServices;

    @Autowired
    private OrderServices orderServices;

    @Autowired
    private ReservationServices reservationServices;

    @GetMapping
    public ResponseEntity<?> getAll() {
        try {
            List<RestaurantTable> tables = restaurantTableServices.getAll();
            return ResponseEntity.ok(tables);
        } catch (Exception ex) {
            return ResponseEntity.internalServerError().body("Lỗi " + ex.getMessage());
        }
    }

    @GetMapping("/{id}")
    public ResponseEntity<?> getById(@PathVariable Integer id) {
        try {
            RestaurantTable table = restaurantTableServices.getById(id);
            if (table == null) {
                return ResponseEntity.notFound().build();
            }
            return ResponseEntity.ok(table);
        } catch (Exception ex) {
            return ResponseEntity.internalServerError().body("Lỗi " + ex.getMessage());
        }
    }

    // Tạo mới bàn
    @PostMapping
    public ResponseEntity<?> create(@RequestBody RestaurantTable table) {
        try {
            RestaurantTable created = restaurantTableServices.create(table);
            return ResponseEntity.ok(created);
        } catch (Exception ex) {
            return ResponseEntity.internalServerError().body("Lỗi " + ex.getMessage());
        }
    }

    @PutMapping("/{id}")
    public ResponseEntity<?> updateTable(@PathVariable Integer id, @RequestBody RestaurantTable table) {
        try {
            RestaurantTable updated = restaurantTableServices.update(id, table);
            if (updated == null) {
                return ResponseEntity.notFound().build();
            }
            return ResponseEntity.ok(updated);
        } catch (Exception ex) {
            return ResponseEntity.internalServerError().body("Lỗi " + ex.getMessage());
        }
    }

    // Xóa bàn
    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteTable(@PathVariable Integer id) {
        try {
            boolean deleted = restaurantTableServices.delete(id);
            if (!deleted) {
                return ResponseEntity.notFound().build();
            }
            return ResponseEntity.noContent().build();
        } catch (Exception ex) {
            return ResponseEntity.internalServerError().body("Lỗi " + ex.getMessage());
        }
    }

    // Lấy bàn theo branchId
    @GetMapping("/branch/{branchId}")
    public ResponseEntity<?> getByBranchId(@PathVariable Integer branchId) {
        try {
            List<RestaurantTable> tables = restaurantTableServices.getByBranchId(branchId);
            return ResponseEntity.ok(tables);
        } catch (Exception ex) {
            return ResponseEntity.internalServerError().body("Lỗi " + ex.getMessage());
        }
    }

    // Thống kê tỷ lệ lấp đầy bàn theo chi nhánh
    @GetMapping("/occupancy/branch/{branchId}")
    public ResponseEntity<?> getTableOccupancyByBranch(@PathVariable Integer branchId) {
        try {
            List<RestaurantTable> tables = restaurantTableServices.getByBranchId(branchId);
            List<Integer> unpaidTableIds = orderServices.getUnpaidOrderTableIdsToday();

            int totalTables = tables.size();
            int occupiedTables = (int) tables.stream()
                    .filter(table -> unpaidTableIds.contains(table.getId()))
                    .count();
            int availableTables = totalTables - occupiedTables;

            double occupancyRate = totalTables > 0 ? (double) occupiedTables / totalTables * 100 : 0;

            Map<String, Object> occupancy = new HashMap<>();
            occupancy.put("branchId", branchId);
            occupancy.put("totalTables", totalTables);
            occupancy.put("occupiedTables", occupiedTables);
            occupancy.put("availableTables", availableTables);
            occupancy.put("occupancyRate", Math.round(occupancyRate * 100.0) / 100.0);
            occupancy.put("timestamp", LocalDateTime.now(ZoneId.of("Asia/Ho_Chi_Minh")).toString());

            return ResponseEntity.ok(occupancy);
        } catch (Exception ex) {
            return ResponseEntity.internalServerError().body("Lỗi " + ex.getMessage());
        }
    }

    // Thống kê hiệu suất sử dụng bàn theo chi nhánh
    @GetMapping("/utilization/branch/{branchId}")
    public ResponseEntity<?> getTableUtilizationByBranch(@PathVariable Integer branchId) {
        try {
            List<RestaurantTable> tables = restaurantTableServices.getByBranchId(branchId);

            // Thống kê từng bàn
            List<Map<String, Object>> tableUtilization = tables.stream()
                    .map(table -> {
                        // Lấy orders hôm nay cho bàn này
                        List<com.smartdine.models.Order> todayOrders = orderServices
                                .getOrdersByTableIdToday(table.getId());

                        Map<String, Object> utilization = new HashMap<>();
                        utilization.put("tableId", table.getId());
                        utilization.put("tableName", table.getName());
                        utilization.put("description", table.getDescription());
                        utilization.put("todayOrderCount", todayOrders.size());
                        utilization.put("isOccupied", !todayOrders.isEmpty() &&
                                todayOrders.stream().anyMatch(order -> order.getStatusId() == 2)); // SERVING status

                        // Tính thời gian sử dụng trung bình (giả định)
                        double avgUsageHours = todayOrders.size() > 0 ? todayOrders.size() * 1.5 : 0; // Giả định mỗi
                                                                                                      // order 1.5h
                        utilization.put("averageUsageHours", avgUsageHours);
                        utilization.put("utilizationScore", Math.min(avgUsageHours / 8.0 * 100, 100)); // % sử dụng
                                                                                                       // trong 8h làm
                                                                                                       // việc

                        return utilization;
                    })
                    .toList();

            // Tổng quan chi nhánh
            double branchUtilizationScore = tableUtilization.stream()
                    .mapToDouble(util -> (Double) util.get("utilizationScore"))
                    .average()
                    .orElse(0.0);

            Map<String, Object> result = new HashMap<>();
            result.put("branchId", branchId);
            result.put("totalTables", tables.size());
            result.put("branchUtilizationScore", Math.round(branchUtilizationScore * 100.0) / 100.0);
            result.put("tableDetails", tableUtilization);
            result.put("timestamp", LocalDateTime.now(ZoneId.of("Asia/Ho_Chi_Minh")).toString());

            return ResponseEntity.ok(result);
        } catch (Exception ex) {
            return ResponseEntity.internalServerError().body("Lỗi " + ex.getMessage());
        }
    }

    // Danh sách bàn có sẵn theo chi nhánh
    @GetMapping("/availability/branch/{branchId}")
    public ResponseEntity<?> getTableAvailabilityByBranch(@PathVariable Integer branchId) {
        try {
            List<RestaurantTable> allTables = restaurantTableServices.getByBranchId(branchId);
            List<Integer> unpaidTableIds = orderServices.getUnpaidOrderTableIdsToday();

            List<Map<String, Object>> tableAvailability = allTables.stream()
                    .map(table -> {
                        boolean isAvailable = !unpaidTableIds.contains(table.getId());

                        Map<String, Object> availability = new HashMap<>();
                        availability.put("tableId", table.getId());
                        availability.put("tableName", table.getName());
                        availability.put("description", table.getDescription());
                        availability.put("isAvailable", isAvailable);
                        availability.put("status", isAvailable ? "AVAILABLE" : "OCCUPIED");

                        if (!isAvailable) {
                            // Lấy order hiện tại của bàn
                            List<com.smartdine.models.Order> currentOrders = orderServices
                                    .getOrdersByTableIdToday(table.getId());
                            availability.put("currentOrderCount", currentOrders.size());
                            availability.put("lastOrderTime", currentOrders.stream()
                                    .map(order -> order.getCreatedAt().toString())
                                    .reduce((first, second) -> second) // Get latest
                                    .orElse("N/A"));
                        }

                        return availability;
                    })
                    .toList();

            // Phân loại bàn
            List<Map<String, Object>> availableTables = tableAvailability.stream()
                    .filter(table -> (Boolean) table.get("isAvailable"))
                    .toList();

            List<Map<String, Object>> occupiedTables = tableAvailability.stream()
                    .filter(table -> !(Boolean) table.get("isAvailable"))
                    .toList();

            Map<String, Object> result = new HashMap<>();
            result.put("branchId", branchId);
            result.put("summary", Map.of(
                    "totalTables", allTables.size(),
                    "availableCount", availableTables.size(),
                    "occupiedCount", occupiedTables.size(),
                    "availabilityRate",
                    allTables.size() > 0
                            ? Math.round((double) availableTables.size() / allTables.size() * 10000.0) / 100.0
                            : 0));
            result.put("availableTables", availableTables);
            result.put("occupiedTables", occupiedTables);
            result.put("timestamp", LocalDateTime.now(ZoneId.of("Asia/Ho_Chi_Minh")).toString());

            return ResponseEntity.ok(result);
        } catch (Exception ex) {
            return ResponseEntity.internalServerError().body("Lỗi " + ex.getMessage());
        }
    }

    // Thống kê bàn ăn theo chi nhánh
    @GetMapping("/statistics/branch/{branchId}")
    public ResponseEntity<?> getTableStatisticsByBranch(@PathVariable Integer branchId) {
        try {
            List<RestaurantTable> allTables = restaurantTableServices.getByBranchId(branchId);
            List<Integer> unpaidTableIds = orderServices.getUnpaidOrderTableIdsToday();

            long occupiedTables = allTables.stream()
                    .mapToInt(RestaurantTable::getId)
                    .filter(unpaidTableIds::contains)
                    .count();

            long availableTables = allTables.size() - occupiedTables;
            double occupancyRate = allTables.size() > 0
                    ? Math.round((double) occupiedTables / allTables.size() * 10000.0) / 100.0
                    : 0;

            // Thống kê theo loại bàn
            Map<String, Integer> tableTypeStats = allTables.stream()
                    .collect(Collectors.groupingBy(
                            table -> table.getTypeId() != null ? "Type " + table.getTypeId() : "Unknown",
                            Collectors.collectingAndThen(Collectors.counting(), Math::toIntExact)));

            Map<String, Object> statistics = new HashMap<>();
            statistics.put("branchId", branchId);
            statistics.put("totalTables", allTables.size());
            statistics.put("occupiedTables", occupiedTables);
            statistics.put("availableTables", availableTables);
            statistics.put("occupancyRate", occupancyRate);
            statistics.put("tableTypeBreakdown", tableTypeStats);
            statistics.put("averageTableSize",
                    allTables.size() > 0 ? allTables.stream().mapToInt(t -> 4).average().orElse(4.0) : 0); // Mock
                                                                                                           // average
            statistics.put("timestamp", LocalDateTime.now(ZoneId.of("Asia/Ho_Chi_Minh")).toString());

            return ResponseEntity.ok(statistics);
        } catch (Exception ex) {
            return ResponseEntity.internalServerError().body("Lỗi " + ex.getMessage());
        }
    }

    // Danh sách bàn với trạng thái đầy đủ (bao gồm order và reservation)
    @GetMapping("/status/branch/{branchId}")
    public ResponseEntity<?> getTableStatusByBranch(@PathVariable Integer branchId) {
        try {
            List<RestaurantTable> allTables = restaurantTableServices.getByBranchId(branchId);
            List<Integer> unpaidTableIds = orderServices.getUnpaidOrderTableIdsToday();

            // Lấy danh sách bàn đã đặt reservation
            Map<String, Object> reservedTablesResponse = reservationServices.getReservedTableIdsByBranch(branchId);
            @SuppressWarnings("unchecked")
            List<Integer> availableReservedTables = (List<Integer>) reservedTablesResponse.get("availableTables");
            @SuppressWarnings("unchecked")
            List<Integer> confirmedReservedTables = (List<Integer>) reservedTablesResponse.get("reservedTables");

            LocalDateTime now = LocalDateTime.now(ZoneId.of("Asia/Ho_Chi_Minh"));

            List<Map<String, Object>> tableStatus = allTables.stream()
                .map(table -> {
                    Map<String, Object> status = new HashMap<>();
                    status.put("tableId", table.getId());
                    status.put("tableName", table.getName());
                    status.put("description", table.getDescription());
                    status.put("branchId", table.getBranchId());

                    // Xác định trạng thái bàn
                    String tableStatusStr;
                    String statusDetail = "";

                    if (unpaidTableIds.contains(table.getId())) {
                        // Bàn đang có order chưa thanh toán
                        tableStatusStr = "OCCUPIED";
                        statusDetail = "Đang phục vụ";

                        // Lấy thông tin order
                        List<com.smartdine.models.Order> currentOrders = orderServices.getOrdersByTableIdToday(table.getId());
                        status.put("currentOrderCount", currentOrders.size());
                        status.put("lastOrderTime", currentOrders.stream()
                            .map(order -> order.getCreatedAt().toString())
                            .reduce((first, second) -> second)
                            .orElse("N/A"));

                    } else if (confirmedReservedTables.contains(table.getId())) {
                        // Bàn đã đặt và không thể hủy (>= 2 tiếng)
                        tableStatusStr = "RESERVED";
                        statusDetail = "Đã đặt trước";

                    } else if (availableReservedTables.contains(table.getId())) {
                        // Bàn đã đặt nhưng có thể hủy (< 2 tiếng)
                        tableStatusStr = "RESERVED_SOFT";
                        statusDetail = "Đặt trước (có thể hủy)";

                    } else {
                        // Bàn trống
                        tableStatusStr = "AVAILABLE";
                        statusDetail = "Bàn trống";
                    }

                    status.put("status", tableStatusStr);
                    status.put("statusDetail", statusDetail);
                    status.put("isAvailable", "AVAILABLE".equals(tableStatusStr));
                    status.put("isOccupied", "OCCUPIED".equals(tableStatusStr));
                    status.put("isReserved", "RESERVED".equals(tableStatusStr) || "RESERVED_SOFT".equals(tableStatusStr));
                    status.put("canCancelReservation", "RESERVED_SOFT".equals(tableStatusStr));

                    return status;
                })
                .toList();

            // Phân loại bàn theo trạng thái
            List<Map<String, Object>> availableTables = tableStatus.stream()
                .filter(table -> "AVAILABLE".equals(table.get("status")))
                .toList();

            List<Map<String, Object>> occupiedTables = tableStatus.stream()
                .filter(table -> "OCCUPIED".equals(table.get("status")))
                .toList();

            List<Map<String, Object>> reservedTables = tableStatus.stream()
                .filter(table -> "RESERVED".equals(table.get("status")) || "RESERVED_SOFT".equals(table.get("status")))
                .toList();

            Map<String, Object> result = new HashMap<>();
            result.put("branchId", branchId);
            result.put("summary", Map.of(
                "totalTables", allTables.size(),
                "availableCount", availableTables.size(),
                "occupiedCount", occupiedTables.size(),
                "reservedCount", reservedTables.size(),
                "availabilityRate", allTables.size() > 0 ?
                    Math.round((double) availableTables.size() / allTables.size() * 10000.0) / 100.0 : 0
            ));
            result.put("availableTables", availableTables);
            result.put("occupiedTables", occupiedTables);
            result.put("reservedTables", reservedTables);
            result.put("allTables", tableStatus);
            result.put("currentTime", now.toString());

            return ResponseEntity.ok(result);

        } catch (Exception ex) {
            ex.printStackTrace();
            return ResponseEntity.internalServerError().body("Lỗi lấy trạng thái bàn: " + ex.getMessage());
        }
    }

}
