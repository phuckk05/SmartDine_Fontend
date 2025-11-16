# Test Fixed URLs for Branch Management APIs
$baseUrl = "https://smartdine-backend-oq2x.onrender.com/api"

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

Write-Host "=== TESTING FIXED URLs ===" -ForegroundColor Green
Write-Host ""

# Test the corrected URLs
Write-Host "CORRECTED URLs:" -ForegroundColor Cyan
Test-API "$baseUrl/roles/all" "Get All Roles (Fixed)"
Test-API "$baseUrl/table-types/all" "Table Types (Fixed)"  
Test-API "$baseUrl/table-statuses/all" "Table Statuses (Fixed)"

Write-Host ""
Write-Host "REMAINING ISSUES:" -ForegroundColor Yellow
Test-API "$baseUrl/users/123" "User by ID (Need Implementation)"
Test-API "$baseUrl/orders/1" "Order by ID (Server Error)"
Test-API "$baseUrl/categories/all" "Categories (Try /all endpoint)"
Test-API "$baseUrl/categories" "Categories (Original endpoint)"

Write-Host ""
Write-Host "=== ANALYSIS ===" -ForegroundColor Magenta
Write-Host "✅ Fixed URLs should resolve table dropdown issues" -ForegroundColor Green
Write-Host "❌ 3 APIs still need backend fixes" -ForegroundColor Red
Write-Host "🎯 Focus: Users API, Orders API, Categories API" -ForegroundColor Cyan