package com.smartdine.controllers;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/notifications")
public class NotificationController {

    @GetMapping("/branch/{branchId}")
    public ResponseEntity<?> getNotificationsByBranch(@PathVariable Integer branchId) {
        try {
            // Mock notifications data - should be replaced with real database
            List<Map<String, Object>> notifications = new ArrayList<>();

            // Sample notifications
            Map<String, Object> notification1 = new HashMap<>();
            notification1.put("id", 1);
            notification1.put("title", "Đơn hàng mới");
            notification1.put("message", "Có đơn hàng mới từ bàn số 5");
            notification1.put("type", "order");
            notification1.put("isRead", false);
            notification1.put("createdAt", LocalDateTime.now().minusMinutes(30));
            notifications.add(notification1);

            Map<String, Object> notification2 = new HashMap<>();
            notification2.put("id", 2);
            notification2.put("title", "Nhân viên đăng nhập");
            notification2.put("message", "Nguyễn Văn A đã đăng nhập vào hệ thống");
            notification2.put("type", "staff");
            notification2.put("isRead", true);
            notification2.put("createdAt", LocalDateTime.now().minusHours(2));
            notifications.add(notification2);

            Map<String, Object> result = new HashMap<>();
            result.put("branchId", branchId);
            result.put("notifications", notifications);
            result.put("unreadCount", notifications.stream().filter(n -> !(Boolean) n.get("isRead")).count());

            return ResponseEntity.ok(result);
        } catch (Exception ex) {
            return ResponseEntity.internalServerError().body("Lỗi lấy thông báo: " + ex.getMessage());
        }
    }

    @GetMapping("/categories")
    public ResponseEntity<?> getNotificationCategories() {
        try {
            List<Map<String, Object>> categories = new ArrayList<>();

            Map<String, Object> category1 = new HashMap<>();
            category1.put("id", 1);
            category1.put("name", "Đơn hàng");
            category1.put("code", "order");
            category1.put("icon", "receipt");
            categories.add(category1);

            Map<String, Object> category2 = new HashMap<>();
            category2.put("id", 2);
            category2.put("name", "Nhân viên");
            category2.put("code", "staff");
            category2.put("icon", "people");
            categories.add(category2);

            Map<String, Object> category3 = new HashMap<>();
            category3.put("id", 3);
            category3.put("name", "Bàn");
            category3.put("code", "table");
            category3.put("icon", "table_restaurant");
            categories.add(category3);

            Map<String, Object> category4 = new HashMap<>();
            category4.put("id", 4);
            category4.put("name", "Hệ thống");
            category4.put("code", "system");
            category4.put("icon", "settings");
            categories.add(category4);

            return ResponseEntity.ok(categories);
        } catch (Exception ex) {
            return ResponseEntity.internalServerError().body("Lỗi lấy danh mục thông báo: " + ex.getMessage());
        }
    }
}