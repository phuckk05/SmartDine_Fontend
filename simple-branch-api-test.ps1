# Comprehensive Branch Management API Test - Simple Version
$baseUrl = "https://smartdine-backend-oq2x.onrender.com/api"
$branchId = 1
$userId = 123
$companyId = 1

function Test-API($url, $name) {
    try {
        $response = Invoke-RestMethod -Uri $url -Method GET -ContentType "application/json" -TimeoutSec 10
        $count = if ($response -is [Array]) { $response.Count } else { "1 object" }
        Write-Host "   ✅ $name : SUCCESS - $count" -ForegroundColor Green
        return $true
    }
    catch {
        $statusCode = $_.Exception.Response.StatusCode.value__
        Write-Host "   ❌ $name : FAILED - Status $statusCode" -ForegroundColor Red
        return $false
    }
}

Write-Host "=== COMPREHENSIVE BRANCH MANAGEMENT API TEST ===" -ForegroundColor Green
Write-Host ""

$totalTests = 0
$passedTests = 0

# BRANCH DASHBOARD SCREEN
Write-Host "1. BRANCH DASHBOARD:" -ForegroundColor Cyan
$totalTests += 4
if (Test-API "$baseUrl/orders/statistics/branch/$branchId" "Dashboard Order Statistics") { $passedTests++ }
if (Test-API "$baseUrl/dashboard/overview/branch/$branchId" "Dashboard Overview") { $passedTests++ }
if (Test-API "$baseUrl/orders/branch/$branchId" "Recent Orders") { $passedTests++ }
if (Test-API "$baseUrl/tables/statistics/branch/$branchId" "Table Statistics") { $passedTests++ }

Write-Host ""

# EMPLOYEE MANAGEMENT SCREEN
Write-Host "2. EMPLOYEE MANAGEMENT:" -ForegroundColor Cyan
$totalTests += 5
if (Test-API "$baseUrl/employees/branch/$branchId" "Get Employees by Branch") { $passedTests++ }
if (Test-API "$baseUrl/employees/performance/branch/$branchId" "Employee Performance") { $passedTests++ }
if (Test-API "$baseUrl/employees/$userId" "Get Employee Details") { $passedTests++ }
if (Test-API "$baseUrl/roles/all" "Get All Roles") { $passedTests++ }
if (Test-API "$baseUrl/user-approval/statistics/$companyId" "Pending Approval Stats") { $passedTests++ }

Write-Host ""

# TABLE MANAGEMENT SCREEN
Write-Host "3. TABLE MANAGEMENT:" -ForegroundColor Cyan
$totalTests += 6
if (Test-API "$baseUrl/tables/branch/$branchId" "Get Tables by Branch") { $passedTests++ }
if (Test-API "$baseUrl/tables/statistics/branch/$branchId" "Table Statistics") { $passedTests++ }
if (Test-API "$baseUrl/tables/occupancy/branch/$branchId" "Table Occupancy") { $passedTests++ }
if (Test-API "$baseUrl/tables/utilization/branch/$branchId" "Table Utilization") { $passedTests++ }
if (Test-API "$baseUrl/table-types/all" "Table Types") { $passedTests++ }
if (Test-API "$baseUrl/table-statuses/all" "Table Statuses") { $passedTests++ }

Write-Host ""

# BRANCH REPORTS SCREEN
Write-Host "4. BRANCH REPORTS:" -ForegroundColor Cyan
$totalTests += 4
if (Test-API "$baseUrl/orders/statistics/branch/$branchId" "Order Reports") { $passedTests++ }
if (Test-API "$baseUrl/employees/performance/branch/$branchId" "Employee Reports") { $passedTests++ }
if (Test-API "$baseUrl/tables/statistics/branch/$branchId" "Table Reports") { $passedTests++ }
if (Test-API "$baseUrl/branches/$branchId/statistics" "Branch Statistics") { $passedTests++ }

Write-Host ""

# SETTINGS SCREEN
Write-Host "5. SETTINGS SCREEN:" -ForegroundColor Cyan
$totalTests += 3
if (Test-API "$baseUrl/branches" "Get All Branches") { $passedTests++ }
if (Test-API "$baseUrl/user-branches/user/$userId" "User Branch Info") { $passedTests++ }
if (Test-API "$baseUrl/employees/$userId" "Current User Info") { $passedTests++ }

Write-Host ""

# ORDER MANAGEMENT
Write-Host "6. ORDER MANAGEMENT:" -ForegroundColor Cyan
$totalTests += 4
if (Test-API "$baseUrl/orders" "Get All Orders") { $passedTests++ }
if (Test-API "$baseUrl/orders/branch/$branchId" "Orders by Branch") { $passedTests++ }
if (Test-API "$baseUrl/orders/statistics/branch/$branchId" "Order Statistics") { $passedTests++ }
if (Test-API "$baseUrl/orders/1" "Order Details") { $passedTests++ }

Write-Host ""

# AUTHENTICATION and SESSION
Write-Host "7. AUTH and SESSION:" -ForegroundColor Cyan
$totalTests += 3
if (Test-API "$baseUrl/users/$userId" "User Profile") { $passedTests++ }
if (Test-API "$baseUrl/user-branches/user/$userId" "User Branch Mapping") { $passedTests++ }
if (Test-API "$baseUrl/roles/all" "Roles") { $passedTests++ }

Write-Host ""

# ADDITIONAL FEATURES
Write-Host "8. ADDITIONAL FEATURES:" -ForegroundColor Cyan
$totalTests += 3
if (Test-API "$baseUrl/items/company/$companyId" "Menu Items") { $passedTests++ }
if (Test-API "$baseUrl/categories" "Item Categories") { $passedTests++ }
if (Test-API "$baseUrl/menus" "Menus") { $passedTests++ }

Write-Host ""
Write-Host "=== TEST SUMMARY ===" -ForegroundColor Green
Write-Host "Total APIs: $totalTests" -ForegroundColor Yellow
Write-Host "Passed: $passedTests" -ForegroundColor Green
Write-Host "Failed: $($totalTests - $passedTests)" -ForegroundColor Red
Write-Host "Success Rate: $([math]::Round(($passedTests / $totalTests) * 100, 1))%" -ForegroundColor Cyan