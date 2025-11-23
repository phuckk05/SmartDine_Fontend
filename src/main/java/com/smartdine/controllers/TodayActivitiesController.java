package com.smartdine.controllers;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.smartdine.models.Order;
import com.smartdine.models.RestaurantTable;
import com.smartdine.models.User;
import com.smartdine.services.OrderServices;
import com.smartdine.services.RestaurantTableServices;
import com.smartdine.services.UserBranchSevices;
import com.smartdine.services.UserService;

@RestController
@RequestMapping("/api/activities")
public class TodayActivitiesController {

    @Autowired
    private OrderServices orderServices;

    @Autowired
    private RestaurantTableServices tableServices;

    @Autowired
    private UserService userService;

    @Autowired
    private UserBranchSevices userBranchServices;

    @GetMapping("/branch/{branchId}")
    public ResponseEntity<?> getTodayActivities(@PathVariable Integer branchId) {
        try {
            LocalDate today = LocalDate.now();
            LocalDateTime startOfDay = today.atStartOfDay();
            LocalDateTime endOfDay = today.atTime(23, 59, 59);

            // Recent orders today
            List<Order> todayOrders = orderServices.getOrdersByBranchId(branchId).stream()
                .filter(order -> order.getCreatedAt().isAfter(startOfDay) && order.getCreatedAt().isBefore(endOfDay))
                .toList();

            // Table status changes
            List<RestaurantTable> tables = tableServices.getByBranchId(branchId);
            List<Map<String, Object>> tableActivities = new ArrayList<>();

            for (RestaurantTable table : tables) {
                if (table.getUpdatedAt() != null &&
                    table.getUpdatedAt().isAfter(startOfDay) &&
                    table.getUpdatedAt().isBefore(endOfDay)) {

                    Map<String, Object> activity = new HashMap<>();
                    activity.put("type", "table_status_change");
                    activity.put("tableId", table.getId());
                    activity.put("tableName", table.getName());
                    activity.put("statusId", table.getStatusId());
                    activity.put("timestamp", table.getUpdatedAt());
                    tableActivities.add(activity);
                }
            }

            // Employee activities (recent logins/updates)
            List<User> employees = userBranchServices.getByBranchId(branchId).stream()
                .map(ub -> userService.getUserById(ub.getUserId()))
                .filter(user -> user != null && user.getDeletedAt() == null)
                .toList();

            List<Map<String, Object>> employeeActivities = new ArrayList<>();
            for (User employee : employees) {
                if (employee.getUpdatedAt() != null &&
                    employee.getUpdatedAt().isAfter(startOfDay) &&
                    employee.getUpdatedAt().isBefore(endOfDay)) {

                    Map<String, Object> activity = new HashMap<>();
                    activity.put("type", "employee_update");
                    activity.put("employeeId", employee.getId());
                    activity.put("employeeName", employee.getFullName());
                    activity.put("timestamp", employee.getUpdatedAt());
                    employeeActivities.add(activity);
                }
            }

            // Combine all activities
            List<Map<String, Object>> allActivities = new ArrayList<>();
            allActivities.addAll(tableActivities);
            allActivities.addAll(employeeActivities);

            // Sort by timestamp (most recent first)
            allActivities.sort((a, b) -> {
                LocalDateTime timeA = (LocalDateTime) a.get("timestamp");
                LocalDateTime timeB = (LocalDateTime) b.get("timestamp");
                return timeB.compareTo(timeA);
            });

            Map<String, Object> result = new HashMap<>();
            result.put("branchId", branchId);
            result.put("date", today.toString());
            result.put("totalOrders", todayOrders.size());
            result.put("activities", allActivities.subList(0, Math.min(20, allActivities.size()))); // Limit to 20 most recent

            return ResponseEntity.ok(result);
        } catch (Exception ex) {
            return ResponseEntity.internalServerError().body("Lỗi lấy hoạt động hôm nay: " + ex.getMessage());
        }
    }
}