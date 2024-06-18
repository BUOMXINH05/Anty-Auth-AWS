Write-Output "Loading environment variables from .env file..."

# Xác định đường dẫn chính xác tới tệp .env
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$envFileName = [System.Environment]::GetEnvironmentVariable("ENV_FILE_NAME")
if (-not $envFileName) {
    $envFileName = ".env"
}
$envFilePath = Join-Path -Path $scriptDir -ChildPath "..\..\$envFileName"

# Kiểm tra xem tệp .env có tồn tại không
if (-Not (Test-Path $envFilePath)) {
    Write-Output "Error: .env file not found at $envFilePath"
    exit 1
}

# Đọc tệp .env
$envContent = Get-Content $envFilePath

# Đặt các biến môi trường
foreach ($line in $envContent) {
    if ($line -match '^\s*#') { continue }  # Bỏ qua các dòng comment
    if ($line -match '^\s*$') { continue }  # Bỏ qua các dòng trống
    $parts = $line -split '=', 2
    if ($parts.Length -eq 2) {
        $name = $parts[0].Trim()
        $value = $parts[1].Trim()
        [System.Environment]::SetEnvironmentVariable($name, $value)
        Write-Output "Set environment variable: $name = $value"
    }
}

Write-Output "Environment variables loaded from $envFilePath."
