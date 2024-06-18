Write-Output "Setting up CloudFront distribution..."

# Load environment variables
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$loadEnvPath = Join-Path -Path $scriptDir -ChildPath "load-env.ps1"
& $loadEnvPath

# Xác định đường dẫn tới tệp .env ở thư mục gốc
$envFilePath = Join-Path -Path $scriptDir -ChildPath "..\..\.env"

# Load CloudFront config
$configPath = Join-Path -Path $scriptDir -ChildPath "..\configs\cloudfront-config.json"
if (-Not (Test-Path $configPath)) {
    Write-Output "Error: Config file not found at $configPath"
    exit 1
}
$config = Get-Content $configPath | ConvertFrom-Json

# Lấy tên bucket từ biến môi trường
$s3BucketName = [System.Environment]::GetEnvironmentVariable("S3_BUCKET_NAME")
if ($s3BucketName -eq $null) {
    Write-Output "Error: S3 bucket name is not set in environment variables."
    exit 1
}

# Thay thế giá trị trong cấu hình
$config.Origins.Items[0].DomainName = "$s3BucketName.s3.amazonaws.com"

# Chuyển đổi cấu hình sang JSON với độ sâu tùy chỉnh
$distributionConfig = $config | ConvertTo-Json -Depth 10 -Compress

# Lưu cấu hình JSON vào tệp tạm thời
$tempJsonFile = [System.IO.Path]::GetTempFileName()
Set-Content -Path $tempJsonFile -Value $distributionConfig

# Kiểm tra xem JSON đã đúng định dạng chưa
Write-Output "Generated JSON configuration:"
Write-Output $distributionConfig

# Tạo CloudFront Distribution
try {
    $distributionId = (aws cloudfront create-distribution --distribution-config file://$tempJsonFile --query 'Distribution.Id' --output text)
    if ($distributionId -ne $null) {
        Add-Content $envFilePath "`nCLOUDFRONT_DISTRIBUTION_ID=$distributionId"
        Write-Output "Created CloudFront distribution with ID: $distributionId"
    } else {
        Write-Output "Error: CloudFront distribution could not be created."
        exit 1
    }
} catch {
    Write-Output "Error: $_"
    exit 1
} finally {
    # Xóa tệp tạm thời
    Remove-Item -Path $tempJsonFile -Force
}
