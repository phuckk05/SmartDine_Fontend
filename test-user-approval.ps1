# Test User Approval System
$baseUrl = "https://smartdine-backend-oq2x.onrender.com/api"

Write-Host "=== TESTING USER APPROVAL SYSTEM ===" -ForegroundColor Green
Write-Host ""

# Get all users to find pending ones
Write-Host "1. Getting all users:" -ForegroundColor Cyan
try {
    $users = Invoke-RestMethod -Uri "$baseUrl/users/all" -Method GET -ContentType "application/json"
    $pendingUsers = $users | Where-Object { $_.statusId -eq 3 }
    
    Write-Host "   Total users: $($users.Count)" -ForegroundColor Yellow
    Write-Host "   Pending users (statusId=3): $($pendingUsers.Count)" -ForegroundColor Yellow
    
    if ($pendingUsers.Count -gt 0) {
        Write-Host "   Pending users list:" -ForegroundColor Blue
        foreach ($user in $pendingUsers) {
            Write-Host "     - $($user.fullName) (ID: $($user.id), Status: $($user.statusId))" -ForegroundColor Blue
        }
        
        # Test approval API
        $testUser = $pendingUsers[0]
        Write-Host ""
        Write-Host "2. Testing approval for: $($testUser.fullName)" -ForegroundColor Cyan
        
        $updateBody = @{ statusId = 1 } | ConvertTo-Json
        
        try {
            Write-Host "   PUT $baseUrl/users/$($testUser.id) with body: $updateBody" -ForegroundColor Yellow
            $response = Invoke-RestMethod -Uri "$baseUrl/users/$($testUser.id)" -Method PUT -ContentType "application/json" -Body $updateBody
            Write-Host "   ✅ SUCCESS - User approved!" -ForegroundColor Green
        } catch {
            Write-Host "   ❌ FAILED - $($_.Exception.Response.StatusCode.value__)" -ForegroundColor Red
        }
    } else {
        Write-Host "   ℹ️  No pending users found for testing" -ForegroundColor Yellow
    }
} catch {
    Write-Host "   ❌ FAILED to get users" -ForegroundColor Red
}

Write-Host ""
Write-Host "=== TEST COMPLETE ===" -ForegroundColor Green