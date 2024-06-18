Write-Output "Setting up S3 bucket..."

# Xác định đường dẫn chính xác tới tệp load-env.ps1 và tệp cấu hình
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$loadEnvPath = Join-Path -Path $scriptDir -ChildPath "load-env.ps1"
$envFilePath = Join-Path -Path $scriptDir -ChildPath "..\..\.env"

# Load environment variables
& $loadEnvPath

# Lấy các biến môi trường cần thiết từ tệp .env
$s3BucketName = [System.Environment]::GetEnvironmentVariable("S3_BUCKET_NAME")
if ($s3BucketName -eq $null) {
    Write-Output "Error: S3 bucket name is not set in environment variables."
    exit 1
}

# Kiểm tra sự tồn tại của bucket và xóa nếu có
$bucketExists = $false
try {
    aws s3api head-bucket --bucket $s3BucketName
    $bucketExists = $true
} catch {
    Write-Output "Bucket $s3BucketName does not exist or could not be accessed. Proceeding to create a new bucket."
}

if ($bucketExists) {
    try {
        Write-Output "Deleting existing S3 bucket $s3BucketName and all its contents..."
        aws s3 rb s3://$s3BucketName --force
        if ($?) {
            Write-Output "S3 bucket $s3BucketName deleted."
        } else {
            Write-Output "Error: S3 bucket $s3BucketName could not be deleted."
        }
    } catch {
        Write-Output "Error: Unable to delete bucket $s3BucketName. Proceeding to create a new bucket."
    }
}

# Tạo bucket S3 nếu chưa tồn tại
aws s3 mb s3://$s3BucketName
if ($?) {
    Write-Output "S3 bucket $s3BucketName created."
} else {
    Write-Output "Error: S3 bucket could not be created."
    exit 1
}

# Thêm thông tin bucket vào tệp .env
Add-Content $envFilePath "S3_BUCKET_NAME=$s3BucketName"

Write-Output "S3 setup completed."
