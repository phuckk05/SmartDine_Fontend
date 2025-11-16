# Test Complete Employee Approval Flow
$baseUrl = "https://smartdine-backend-oq2x.onrender.com/api"
$branchId = 1

Write-Host "=== EMPLOYEE APPROVAL FLOW TEST ===" -ForegroundColor Green
Write-Host ""

# Step 1: Check current active employees 
Write-Host "1. Active employees (main screen display):" -ForegroundColor Cyan
try {
    $allEmployees = Invoke-RestMethod -Uri "$baseUrl/employees/branch/$branchId" -Method GET -ContentType "application/json"
    $activeEmployees = $allEmployees | Where-Object { $_.statusId -eq 1 }
    Write-Host "   SUCCESS - $($activeEmployees.Count) active employees displayed" -ForegroundColor Green
    
    foreach ($emp in $activeEmployees) {
        Write-Host "     • $($emp.fullName) (Status: $($emp.statusId))" -ForegroundColor Blue
    }
} catch {
    Write-Host "   FAILED - Cannot get active employees" -ForegroundColor Red
}

Write-Host ""

# Step 2: Check pending count for button
Write-Host "2. Pending employees count (for button display):" -ForegroundColor Cyan
try {
    $pendingUsers = Invoke-RestMethod -Uri "$baseUrl/user-approval/pending/branch/$branchId" -Method GET -ContentType "application/json"
    Write-Host "   SUCCESS - Button should show 'Nhân viên chờ duyệt ($($pendingUsers.Count))'" -ForegroundColor Green
    
    if ($pendingUsers.Count -gt 0) {
        Write-Host "   Pending user details:" -ForegroundColor Yellow
        foreach ($user in $pendingUsers) {
            Write-Host "     • ID: $($user.id), Name: $($user.fullName), Status: $($user.statusId)" -ForegroundColor Blue
        }
        
        # Step 3: Simulate approval process
        Write-Host ""
        Write-Host "3. Approval process simulation:" -ForegroundColor Cyan
        $firstPending = $pendingUsers[0]
        Write-Host "   Target user: $($firstPending.fullName) (ID: $($firstPending.id))" -ForegroundColor Yellow
        Write-Host "   Current status: $($firstPending.statusId)" -ForegroundColor Yellow
        Write-Host "   Approval endpoint: PUT $baseUrl/user-approval/approve/$($firstPending.id)" -ForegroundColor Yellow
        Write-Host "   Expected result: Status $($firstPending.statusId) -> Status 1" -ForegroundColor Yellow
        Write-Host "   NOTE: Not executing actual approval to preserve data" -ForegroundColor Orange
    }
} catch {
    Write-Host "   FAILED - Cannot get pending employees" -ForegroundColor Red
}

Write-Host ""
Write-Host "=== FLOW VERIFICATION COMPLETE ===" -ForegroundColor Green
Write-Host "Expected behavior:" -ForegroundColor White
Write-Host "1. Main screen shows active employees only" -ForegroundColor White  
Write-Host "2. Orange button shows pending count" -ForegroundColor White
Write-Host "3. Dialog shows pending employee details" -ForegroundColor White
Write-Host "4. Approve button changes statusId 3 -> 1" -ForegroundColor White