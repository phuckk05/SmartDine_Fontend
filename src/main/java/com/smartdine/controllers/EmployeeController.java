package com.smartdine.controllers;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.util.ArrayList;
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

import com.smartdine.models.Order;
import com.smartdine.models.User;
import com.smartdine.models.UserBranch;
import com.smartdine.services.OrderServices;
import com.smartdine.services.PaymentService;
import com.smartdine.services.UserBranchSevices;
import com.smartdine.services.UserService;

@RestController
@RequestMapping("/api/employees")
public class EmployeeController {

    @Autowired
    private UserService userService;

    @Autowired
    private UserBranchSevices userBranchServices;

    @Autowired
    private OrderServices orderServices;

    @Autowired
    private PaymentService paymentService;

    // Lấy tất cả nhân viên
    @GetMapping
    public ResponseEntity<?> getAllEmployees() {
        try {
            List<User> employees = userService.getAllUsers();
            return ResponseEntity.ok(employees);
        } catch (Exception ex) {
            return ResponseEntity.internalServerError().body("Lỗi " + ex.getMessage());
        }
    }

    // Lấy nhân viên theo chi nhánh
    @GetMapping("/branch/{branchId}")
    public ResponseEntity<?> getEmployeesByBranch(@PathVariable Integer branchId) {
        try {
            // Lấy danh sách UserBranch theo branchId
            List<UserBranch> userBranches = userBranchServices.getByBranchId(branchId);
            
            // Lấy thông tin User tương ứng
            List<User> employees = userBranches.stream()
                .map(ub -> userService.getUserById(ub.getUserId()))
                .filter(user -> user != null && user.getDeletedAt() == null) // Chỉ lấy user chưa bị xóa
                .collect(Collectors.toList());
                
            return ResponseEntity.ok(employees);
        } catch (Exception ex) {
            return ResponseEntity.internalServerError().body("Lỗi " + ex.getMessage());
        }
    }

    // Lấy nhân viên theo ID
    @GetMapping("/{id}")
    public ResponseEntity<?> getEmployeeById(@PathVariable Integer id) {
        try {
            User employee = userService.getUserById(id);
            if (employee == null) {
                return ResponseEntity.notFound().build();
            }
            return ResponseEntity.ok(employee);
        } catch (Exception ex) {
            return ResponseEntity.internalServerError().body("Lỗi " + ex.getMessage());
        }
    }

    // Thêm nhân viên mới
    @PostMapping
    public ResponseEntity<?> createEmployee(@RequestBody Map<String, Object> request) {
        try {
            // Tạo User object từ request
            User employee = new User();
            employee.setFullName((String) request.get("fullName"));
            employee.setEmail((String) request.get("email"));
            employee.setPhone((String) request.get("phone"));
            
            // Nhận raw password và để UserService tự hash
            String password = (String) request.get("password");
            if (password == null) {
                // Fallback: nếu frontend gửi passworkHash thì dùng đó
                password = (String) request.get("passworkHash");
            }
            employee.setPassworkHash(password); // UserService sẽ tự hash nếu chưa được hash
            
            employee.setRole((Integer) request.get("role"));
            employee.setCompanyId((Integer) request.get("companyId"));
            employee.setStatusId(0); // Chờ duyệt by default
            
            // Tạo user
            User createdEmployee = userService.createUser(employee);
            
            // Nếu có branchId, thêm vào UserBranch
            Integer branchId = (Integer) request.get("branchId");
            if (branchId != null) {
                UserBranch userBranch = new UserBranch();
                userBranch.setUserId(createdEmployee.getId());
                userBranch.setBranchId(branchId);
                userBranchServices.create(userBranch);
            }
            
            return ResponseEntity.ok(createdEmployee);
        } catch (Exception ex) {
            return ResponseEntity.internalServerError().body("Lỗi " + ex.getMessage());
        }
    }

    // Cập nhật nhân viên
    @PutMapping("/{id}")
    public ResponseEntity<?> updateEmployee(@PathVariable Integer id, @RequestBody User employee) {
        try {
            User updated = userService.updateUser(id, employee);
            if (updated == null) {
                return ResponseEntity.notFound().build();
            }
            return ResponseEntity.ok(updated);
        } catch (Exception ex) {
            return ResponseEntity.internalServerError().body("Lỗi " + ex.getMessage());
        }
    }

    // Xóa nhân viên
    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteEmployee(@PathVariable Integer id) {
        try {
            boolean deleted = userService.deleteUser(id);
            if (!deleted) {
                return ResponseEntity.notFound().build();
            }
            return ResponseEntity.noContent().build();
        } catch (Exception ex) {
            return ResponseEntity.internalServerError().body("Lỗi " + ex.getMessage());
        }
    }

    // Thống kê hiệu suất nhân viên theo chi nhánh
    @GetMapping("/performance/branch/{branchId}")
    public ResponseEntity<?> getEmployeePerformanceByBranch(@PathVariable Integer branchId) {
        try {
            // Lấy danh sách nhân viên theo chi nhánh
            List<UserBranch> userBranches = userBranchServices.getByBranchId(branchId);

            // Thời gian hiện tại và khoảng thời gian (tuần này)
            LocalDateTime now = LocalDateTime.now(ZoneId.of("Asia/Ho_Chi_Minh"));
            LocalDateTime startOfWeek = now.minusDays(now.getDayOfWeek().getValue() - 1).withHour(0).withMinute(0).withSecond(0).withNano(0);
            LocalDateTime endOfWeek = startOfWeek.plusDays(6).withHour(23).withMinute(59).withSecond(59).withNano(999999999);

            List<Map<String, Object>> performance = userBranches.stream()
                .map(ub -> {
                    User employee = userService.getUserById(ub.getUserId());
                    if (employee != null && employee.getDeletedAt() == null) {
                        Map<String, Object> perfMap = new HashMap<>();
                        perfMap.put("employeeId", employee.getId());
                        perfMap.put("fullName", employee.getFullName());
                        perfMap.put("email", employee.getEmail());
                        perfMap.put("role", employee.getRole());
                        perfMap.put("assignedAt", ub.getAssignedAt());

                        // Tính toán metrics thực tế
                        Long ordersHandled = orderServices.getOrdersHandledByEmployee(employee.getId(), branchId, startOfWeek, endOfWeek);
                        BigDecimal revenue = paymentService.getRevenueByCashierAndBranch(employee.getId(), branchId, startOfWeek, endOfWeek);

                        // Tính rating dựa trên tỷ lệ hoàn thành orders (giả định statusId = 3 là hoàn thành)
                        List<Order> employeeOrders = orderServices.getOrdersByEmployee(employee.getId(), branchId, startOfWeek, endOfWeek);
                        long completedOrders = employeeOrders.stream()
                            .filter(order -> order.getStatusId() == 3) // Giả định 3 = completed
                            .count();
                        double rating = employeeOrders.isEmpty() ? 0.0 :
                            (completedOrders * 1.0 / employeeOrders.size()) * 5.0; // Rating 0-5

                        perfMap.put("ordersHandled", ordersHandled);
                        perfMap.put("revenue", revenue.doubleValue());
                        perfMap.put("rating", Math.round(rating * 10.0) / 10.0); // Làm tròn 1 chữ số thập phân

                        return perfMap;
                    }
                    return null;
                })
                .filter(perfMap -> perfMap != null)
                .collect(Collectors.toList());

            return ResponseEntity.ok(performance);
        } catch (Exception ex) {
            return ResponseEntity.internalServerError().body("Lỗi " + ex.getMessage());
        }
    }

    // Assign nhân viên vào chi nhánh
    @PostMapping("/{employeeId}/assign-branch/{branchId}")
    public ResponseEntity<?> assignEmployeeToBranch(@PathVariable Integer employeeId, @PathVariable Integer branchId) {
        try {
            // Kiểm tra employee tồn tại
            User employee = userService.getUserById(employeeId);
            if (employee == null) {
                return ResponseEntity.notFound().build();
            }
            
            // Tạo UserBranch assignment
            UserBranch userBranch = new UserBranch();
            userBranch.setUserId(employeeId);
            userBranch.setBranchId(branchId);
            
            UserBranch created = userBranchServices.create(userBranch);
            return ResponseEntity.ok(created);
        } catch (Exception ex) {
            return ResponseEntity.internalServerError().body("Lỗi " + ex.getMessage());
        }
    }



    // Cập nhật trạng thái nhân viên hàng loạt
    @PutMapping("/batch-status")
    public ResponseEntity<?> updateEmployeeStatusBatch(@RequestBody Map<String, Object> request) {
        try {
            @SuppressWarnings("unchecked")
            List<Integer> employeeIds = (List<Integer>) request.get("employeeIds");
            Integer statusId = (Integer) request.get("statusId");
            
            if (employeeIds == null || statusId == null) {
                return ResponseEntity.badRequest().body("employeeIds và statusId là bắt buộc");
            }
            
            List<User> updatedEmployees = new ArrayList<>();
            for (Integer employeeId : employeeIds) {
                User employee = userService.getUserById(employeeId);
                if (employee != null) {
                    employee.setStatusId(statusId);
                    User updated = userService.updateUser(employeeId, employee);
                    if (updated != null) {
                        updatedEmployees.add(updated);
                    }
                }
            }
            
            Map<String, Object> result = new HashMap<>();
            result.put("updatedCount", updatedEmployees.size());
            result.put("employees", updatedEmployees);
            
            return ResponseEntity.ok(result);
        } catch (Exception ex) {
            return ResponseEntity.internalServerError().body("Lỗi " + ex.getMessage());
        }
    }

    // Helper method để lấy employees theo branchId
    private List<User> getEmployeesByBranchId(Integer branchId) {
        List<UserBranch> userBranches = userBranchServices.getByBranchId(branchId);
        
        return userBranches.stream()
            .map(ub -> userService.getUserById(ub.getUserId()))
            .filter(user -> user != null && user.getDeletedAt() == null)
            .collect(java.util.stream.Collectors.toList());
    }
}
