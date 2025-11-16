# Test Employee Approval Functionality
$baseUrl = "https://smartdine-backend-oq2x.onrender.com/api"
$branchId = 1

Write-Host "=== TESTING EMPLOYEE APPROVAL FUNCTIONALITY ===" -ForegroundColor Green
Write-Host ""

# Test 1: Get all employees by branch
Write-Host "1. Getting all employees by branch ${branchId}:" -ForegroundColor Cyan
try {
    $allEmployees = Invoke-RestMethod -Uri "$baseUrl/employees/branch/$branchId" -Method GET -ContentType "application/json"
    Write-Host "   ✅ SUCCESS - Found $($allEmployees.Count) total employees" -ForegroundColor Green
    
    # Show status distribution
    $statusGroups = $allEmployees | Group-Object statusId
    foreach ($group in $statusGroups) {
        $statusName = switch ($group.Name) {
            "1" { "Active (statusId=1)" }
            "2" { "Inactive (statusId=2)" } 
            "3" { "Pending/Locked (statusId=3)" }
            default { "Unknown status ($($group.Name))" }
        }
        Write-Host "     - $($group.Count) employees with $statusName" -ForegroundColor Yellow
    }
    
    # Show pending employees details
    $pendingEmployees = $allEmployees | Where-Object { $_.statusId -eq 3 }
    if ($pendingEmployees.Count -gt 0) {
        Write-Host "   📋 Pending employees (statusId=3):" -ForegroundColor Blue
        foreach ($emp in $pendingEmployees) {
            Write-Host "     • ID: $($emp.id), Name: $($emp.fullName), Role: $($emp.role)" -ForegroundColor Blue
        }
    } else {
        Write-Host "   ℹ️  No pending employees found" -ForegroundColor Yellow
    }
} catch {
    Write-Host "   ❌ FAILED - Status: $($_.Exception.Response.StatusCode.value__)" -ForegroundColor Red
    Write-Host "   Error: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""

# Test 2: Test user-approval endpoints
Write-Host "2. Testing user-approval endpoints:" -ForegroundColor Cyan
Write-Host "   a) Pending users by branch:" -ForegroundColor White
try {
    $pendingUsers = Invoke-RestMethod -Uri "$baseUrl/user-approval/pending/branch/${branchId}" -Method GET -ContentType "application/json"
    Write-Host "     ✅ SUCCESS - Found $($pendingUsers.Count) pending users" -ForegroundColor Green
    if ($pendingUsers.Count -gt 0) {
        foreach ($user in $pendingUsers[0..2]) {
            Write-Host "       • $($user.fullName) (ID: $($user.id), Status: $($user.statusId))" -ForegroundColor Blue
        }
    }
} catch {
    Write-Host "     ❌ FAILED - Status: $($_.Exception.Response.StatusCode.value__)" -ForegroundColor Red
}

Write-Host "   b) Locked users by branch:" -ForegroundColor White
try {
    $lockedUsers = Invoke-RestMethod -Uri "$baseUrl/user-approval/locked/branch/${branchId}" -Method GET -ContentType "application/json"
    Write-Host "     ✅ SUCCESS - Found $($lockedUsers.Count) locked users" -ForegroundColor Green
    if ($lockedUsers.Count -gt 0) {
        foreach ($user in $lockedUsers[0..2]) {
            Write-Host "       • $($user.fullName) (ID: $($user.id), Status: $($user.statusId))" -ForegroundColor Blue
        }
    }
} catch {
    Write-Host "     ❌ FAILED - Status: $($_.Exception.Response.StatusCode.value__)" -ForegroundColor Red
}

Write-Host ""

# Test 3: Test approval functionality (if we have pending users)
Write-Host "3. Testing approval functionality:" -ForegroundColor Cyan
try {
    # Get first pending user to test approval
    $testUser = $null
    if ($allEmployees) {
        $testUser = $allEmployees | Where-Object { $_.statusId -eq 3 } | Select-Object -First 1
    }
    
    if ($testUser) {
        Write-Host "   Found test user: $($testUser.fullName) (ID: $($testUser.id))" -ForegroundColor Yellow
        Write-Host "   Testing approval endpoint: PUT $baseUrl/user-approval/approve/$($testUser.id)" -ForegroundColor Yellow
        Write-Host "   ⚠️  Skipping actual approval to avoid data changes" -ForegroundColor Yellow
    } else {
        Write-Host "   ℹ️  No pending users available for approval testing" -ForegroundColor Yellow
    }
} catch {
    Write-Host "   ❌ Error in approval test setup" -ForegroundColor Red
}

Write-Host ""
Write-Host "=== TEST COMPLETE ===" -ForegroundColor Green