package com.smartdine.controllers;

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

import com.smartdine.models.User;
import com.smartdine.models.UserBranch;
import com.smartdine.services.UserBranchSevices;
import com.smartdine.services.UserService;

@RestController
@RequestMapping("/api/employees")
public class EmployeeController {

    @Autowired
    private UserService userService;

    @Autowired
    private UserBranchSevices userBranchServices;

    // Lấy tất cả nhân viên
    @GetMapping("/all")
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
            employee.setPassworkHash((String) request.get("password"));
            employee.setRole((Integer) request.get("role"));
            employee.setCompanyId((Integer) request.get("companyId"));
            employee.setStatusId(1); // Active by default
            
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
                        
                        // TODO: Thêm metrics thực tế như số đơn xử lý, doanh thu, etc.
                        // Hiện tại return dữ liệu cơ bản
                        perfMap.put("ordersHandled", 0);
                        perfMap.put("revenue", 0.0);
                        perfMap.put("rating", 0.0);
                        
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
}
