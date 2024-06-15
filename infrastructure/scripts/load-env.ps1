Write-Output "Loading environment variables from .env file..."

# Xác định đường dẫn chính xác tới tệp .env ở thư mục gốc
$projectRoot = (Resolve-Path -Path "$PSScriptRoot\..\..").Path
$envFilePath = Join-Path -Path $projectRoot -ChildPath ".env"

if (Test-Path $envFilePath) {
    Get-Content $envFilePath | ForEach-Object {
        if ($_ -match "^([^#].*?)=(.*)$") {
            [System.Environment]::SetEnvironmentVariable($matches[1], $matches[2])
        }
    }
    Write-Output "Environment variables loaded from $envFilePath."
} else {
    Write-Output "Error: .env file not found at path $envFilePath."
    exit 1
}
