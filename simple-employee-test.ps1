# Simple Employee Approval Test
$baseUrl = "https://smartdine-backend-oq2x.onrender.com/api"
$branchId = 1

Write-Host "Testing Employee Approval System" -ForegroundColor Green
Write-Host ""

Write-Host "1. All employees by branch:" -ForegroundColor Cyan
try {
    $employees = Invoke-RestMethod -Uri "$baseUrl/employees/branch/$branchId" -Method GET -ContentType "application/json"
    Write-Host "   SUCCESS - $($employees.Count) total employees" -ForegroundColor Green
    
    $pending = $employees | Where-Object { $_.statusId -eq 3 }
    Write-Host "   Pending employees (statusId=3): $($pending.Count)" -ForegroundColor Yellow
    
    if ($pending.Count -gt 0) {
        foreach ($emp in $pending) {
            Write-Host "     - $($emp.fullName) (ID: $($emp.id))" -ForegroundColor Blue
        }
    }
} catch {
    Write-Host "   FAILED - $($_.Exception.Response.StatusCode.value__)" -ForegroundColor Red
}

Write-Host ""
Write-Host "2. User approval - pending by branch:" -ForegroundColor Cyan
try {
    $pendingUsers = Invoke-RestMethod -Uri "$baseUrl/user-approval/pending/branch/$branchId" -Method GET -ContentType "application/json"
    Write-Host "   SUCCESS - $($pendingUsers.Count) pending users" -ForegroundColor Green
} catch {
    Write-Host "   FAILED - $($_.Exception.Response.StatusCode.value__)" -ForegroundColor Red
}

Write-Host ""
Write-Host "3. User approval - locked by branch:" -ForegroundColor Cyan
try {
    $lockedUsers = Invoke-RestMethod -Uri "$baseUrl/user-approval/locked/branch/$branchId" -Method GET -ContentType "application/json"
    Write-Host "   SUCCESS - $($lockedUsers.Count) locked users" -ForegroundColor Green
} catch {
    Write-Host "   FAILED - $($_.Exception.Response.StatusCode.value__)" -ForegroundColor Red
}

Write-Host ""
Write-Host "Test Complete!" -ForegroundColor Green