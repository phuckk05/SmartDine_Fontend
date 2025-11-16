# Comprehensive Branch Management API Test
# Kiểm tra TẤT CẢ APIs được sử dụng trong các màn hình branch_management

$baseUrl = "https://smartdine-backend-oq2x.onrender.com/api"
$branchId = 1
$userId = 123
$companyId = 1
$today = (Get-Date).ToString("yyyy-MM-dd")

Write-Host "=== COMPREHENSIVE BRANCH MANAGEMENT API TEST ===" -ForegroundColor Green
Write-Host "Testing ALL APIs used in Branch Management features" -ForegroundColor Yellow
Write-Host "BranchId: $branchId | UserId: $userId | CompanyId: $companyId" -ForegroundColor Cyan
Write-Host ""

# 1. BRANCH DASHBOARD SCREEN
Write-Host "1. 🏠 BRANCH DASHBOARD SCREEN APIs:" -ForegroundColor Cyan
$dashboardAPIs = @(
    @{ url = "$baseUrl/orders/statistics/branch/$branchId"; name = "Dashboard Order Statistics"; screen = "Dashboard" },
    @{ url = "$baseUrl/dashboard/overview/branch/$branchId"; name = "Dashboard Overview"; screen = "Dashboard" },
    @{ url = "$baseUrl/orders/branch/$branchId"; name = "Recent Orders"; screen = "Dashboard" },
    @{ url = "$baseUrl/tables/statistics/branch/$branchId"; name = "Table Statistics"; screen = "Dashboard" }
)

foreach ($api in $dashboardAPIs) {
    try {
        $response = Invoke-RestMethod -Uri $api.url -Method GET -ContentType "application/json" -TimeoutSec 10
        $count = if ($response -is [Array]) { $response.Count } else { "1 object" }
        Write-Host "   ✅ $($api.name): SUCCESS - $count" -ForegroundColor Green
    }
    catch {
        $statusCode = $_.Exception.Response.StatusCode.value__
        Write-Host "   ❌ $($api.name): FAILED - Status $statusCode" -ForegroundColor Red
    }
}

Write-Host ""

# 2. EMPLOYEE MANAGEMENT SCREEN  
Write-Host "2. 👥 EMPLOYEE MANAGEMENT SCREEN APIs:" -ForegroundColor Cyan
$employeeAPIs = @(
    @{ url = "$baseUrl/employees/branch/$branchId"; name = "Get Employees by Branch"; screen = "Employee Mgmt" },
    @{ url = "$baseUrl/employees/performance/branch/$branchId"; name = "Employee Performance"; screen = "Employee Mgmt" },
    @{ url = "$baseUrl/employees/$userId"; name = "Get Employee Details"; screen = "Employee Mgmt" },
    @{ url = "$baseUrl/roles"; name = "Get All Roles"; screen = "Employee Mgmt" },
    @{ url = "$baseUrl/user-approval/statistics/$companyId"; name = "Pending Approval Stats"; screen = "Employee Mgmt" }
)

foreach ($api in $employeeAPIs) {
    try {
        $response = Invoke-RestMethod -Uri $api.url -Method GET -ContentType "application/json" -TimeoutSec 10
        $count = if ($response -is [Array]) { $response.Count } else { "1 object" }
        Write-Host "   ✅ $($api.name): SUCCESS - $count" -ForegroundColor Green
    }
    catch {
        $statusCode = $_.Exception.Response.StatusCode.value__
        Write-Host "   ❌ $($api.name): FAILED - Status $statusCode" -ForegroundColor Red
    }
}

Write-Host ""

# 3. TABLE MANAGEMENT SCREEN
Write-Host "3. 🍽️ TABLE MANAGEMENT SCREEN APIs:" -ForegroundColor Cyan
$tableAPIs = @(
    @{ url = "$baseUrl/tables/branch/$branchId"; name = "Get Tables by Branch"; screen = "Table Mgmt" },
    @{ url = "$baseUrl/tables/statistics/branch/$branchId"; name = "Table Statistics"; screen = "Table Mgmt" },
    @{ url = "$baseUrl/tables/occupancy/branch/$branchId"; name = "Table Occupancy"; screen = "Table Mgmt" },
    @{ url = "$baseUrl/tables/utilization/branch/$branchId"; name = "Table Utilization"; screen = "Table Mgmt" },
    @{ url = "$baseUrl/table-types"; name = "Table Types"; screen = "Table Mgmt" },
    @{ url = "$baseUrl/table-statuses"; name = "Table Statuses"; screen = "Table Mgmt" }
)

foreach ($api in $tableAPIs) {
    try {
        $response = Invoke-RestMethod -Uri $api.url -Method GET -ContentType "application/json" -TimeoutSec 10
        $count = if ($response -is [Array]) { $response.Count } else { "1 object" }
        Write-Host "   ✅ $($api.name): SUCCESS - $count" -ForegroundColor Green
    }
    catch {
        $statusCode = $_.Exception.Response.StatusCode.value__
        Write-Host "   ❌ $($api.name): FAILED - Status $statusCode" -ForegroundColor Red
    }
}

Write-Host ""

# 4. BRANCH REPORTS SCREEN
Write-Host "4. 📊 BRANCH REPORTS SCREEN APIs:" -ForegroundColor Cyan
$reportsAPIs = @(
    @{ url = "$baseUrl/orders/statistics/branch/$branchId"; name = "Order Reports"; screen = "Reports" },
    @{ url = "$baseUrl/orders/statistics/period/$branchId?startDate=2025-11-01`&endDate=2025-11-17"; name = "Period Reports"; screen = "Reports" },
    @{ url = "$baseUrl/employees/performance/branch/$branchId"; name = "Employee Reports"; screen = "Reports" },
    @{ url = "$baseUrl/tables/statistics/branch/$branchId"; name = "Table Reports"; screen = "Reports" },
    @{ url = "$baseUrl/branches/$branchId/statistics"; name = "Branch Statistics"; screen = "Reports" }
)

foreach ($api in $reportsAPIs) {
    try {
        $response = Invoke-RestMethod -Uri $api.url -Method GET -ContentType "application/json" -TimeoutSec 10
        $count = if ($response -is [Array]) { $response.Count } else { "1 object" }
        Write-Host "   ✅ $($api.name): SUCCESS - $count" -ForegroundColor Green
    }
    catch {
        $statusCode = $_.Exception.Response.StatusCode.value__
        Write-Host "   ❌ $($api.name): FAILED - Status $statusCode" -ForegroundColor Red
    }
}

Write-Host ""

# 5. SETTINGS SCREEN
Write-Host "5. ⚙️ SETTINGS SCREEN APIs:" -ForegroundColor Cyan
$settingsAPIs = @(
    @{ url = "$baseUrl/branches"; name = "Get All Branches"; screen = "Settings" },
    @{ url = "$baseUrl/user-branches/user/$userId"; name = "User Branch Info"; screen = "Settings" },
    @{ url = "$baseUrl/employees/$userId"; name = "Current User Info"; screen = "Settings" }
)

foreach ($api in $settingsAPIs) {
    try {
        $response = Invoke-RestMethod -Uri $api.url -Method GET -ContentType "application/json" -TimeoutSec 10
        $count = if ($response -is [Array]) { $response.Count } else { "1 object" }
        Write-Host "   ✅ $($api.name): SUCCESS - $count" -ForegroundColor Green
    }
    catch {
        $statusCode = $_.Exception.Response.StatusCode.value__
        Write-Host "   ❌ $($api.name): FAILED - Status $statusCode" -ForegroundColor Red
    }
}

Write-Host ""

# 6. ORDER MANAGEMENT (Used in multiple screens)
Write-Host "6. 📦 ORDER MANAGEMENT APIs:" -ForegroundColor Cyan
$orderAPIs = @(
    @{ url = "$baseUrl/orders"; name = "Get All Orders"; screen = "Multiple" },
    @{ url = "$baseUrl/orders/branch/$branchId"; name = "Orders by Branch"; screen = "Multiple" },
    @{ url = "$baseUrl/orders/statistics/branch/$branchId"; name = "Order Statistics"; screen = "Multiple" },
    @{ url = "$baseUrl/orders/1"; name = "Order Details (ID=1)"; screen = "Order Detail" }
)

foreach ($api in $orderAPIs) {
    try {
        $response = Invoke-RestMethod -Uri $api.url -Method GET -ContentType "application/json" -TimeoutSec 10
        $count = if ($response -is [Array]) { $response.Count } else { "1 object" }
        Write-Host "   ✅ $($api.name): SUCCESS - $count" -ForegroundColor Green
    }
    catch {
        $statusCode = $_.Exception.Response.StatusCode.value__
        Write-Host "   ❌ $($api.name): FAILED - Status $statusCode" -ForegroundColor Red
    }
}

Write-Host ""

# 7. AUTHENTICATION & SESSION APIs
Write-Host "7. 🔐 AUTH and SESSION APIs:" -ForegroundColor Cyan
$authAPIs = @(
    @{ url = "$baseUrl/users/$userId"; name = "User Profile"; screen = "Session" },
    @{ url = "$baseUrl/user-branches/user/$userId"; name = "User Branch Mapping"; screen = "Session" },
    @{ url = "$baseUrl/roles"; name = "Available Roles"; screen = "Auth" }
)

foreach ($api in $authAPIs) {
    try {
        $response = Invoke-RestMethod -Uri $api.url -Method GET -ContentType "application/json" -TimeoutSec 10
        $count = if ($response -is [Array]) { $response.Count } else { "1 object" }
        Write-Host "   ✅ $($api.name): SUCCESS - $count" -ForegroundColor Green
    }
    catch {
        $statusCode = $_.Exception.Response.StatusCode.value__
        Write-Host "   ❌ $($api.name): FAILED - Status $statusCode" -ForegroundColor Red
    }
}

Write-Host ""

# 8. ADDITIONAL FEATURES (Performance, Analytics, etc.)
Write-Host "8. 📈 ADDITIONAL FEATURE APIs:" -ForegroundColor Cyan
$additionalAPIs = @(
    @{ url = "$baseUrl/items/company/$companyId"; name = "Menu Items"; screen = "Kitchen/Menu" },
    @{ url = "$baseUrl/categories"; name = "Item Categories"; screen = "Kitchen/Menu" },
    @{ url = "$baseUrl/menus"; name = "Menus"; screen = "Kitchen/Menu" }
)

foreach ($api in $additionalAPIs) {
    try {
        $response = Invoke-RestMethod -Uri $api.url -Method GET -ContentType "application/json" -TimeoutSec 10
        $count = if ($response -is [Array]) { $response.Count } else { "1 object" }
        Write-Host "   ✅ $($api.name): SUCCESS - $count" -ForegroundColor Green
    }
    catch {
        $statusCode = $_.Exception.Response.StatusCode.value__
        Write-Host "   ❌ $($api.name): FAILED - Status $statusCode" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "=== COMPREHENSIVE TEST SUMMARY ===" -ForegroundColor Green

# Count successes and failures
$totalTests = $dashboardAPIs.Count + $employeeAPIs.Count + $tableAPIs.Count + $reportsAPIs.Count + $settingsAPIs.Count + $orderAPIs.Count + $authAPIs.Count + $additionalAPIs.Count
Write-Host "Total APIs tested: $totalTests" -ForegroundColor Yellow

Write-Host ""
Write-Host "✅ = API Working | ❌ = API Failed" -ForegroundColor Gray
Write-Host "🎯 Focus on fixing FAILED APIs for full Branch Management functionality" -ForegroundColor Magenta
Write-Host ""