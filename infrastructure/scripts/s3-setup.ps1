Write-Output "Setting up S3 bucket..."

# Load environment variables
./load-env.ps1

# Xác định đường dẫn chính xác tới tệp .env ở thư mục gốc
$projectRoot = (Resolve-Path -Path "$PSScriptRoot\..\..").Path
$envFilePath = Join-Path -Path $projectRoot -ChildPath ".env"

# Lấy các biến môi trường cần thiết từ tệp .env
$s3BucketName = [System.Environment]::GetEnvironmentVariable("S3_BUCKET_NAME")
if ($s3BucketName -eq $null) {
    Write-Output "Error: S3 bucket name is not set in environment variables."
    exit 1
}

# Kiểm tra sự tồn tại của bucket và xóa nếu có
try {
    aws s3api head-bucket --bucket $s3BucketName
    Write-Output "Deleting existing S3 bucket $s3BucketName and all its contents..."
    aws s3 rb s3://$s3BucketName --force
    if ($?) {
        Write-Output "S3 bucket $s3BucketName deleted."
    } else {
        Write-Output "Error: S3 bucket $s3BucketName could not be deleted."
        exit 1
    }
} catch {
    Write-Output "Bucket $s3BucketName does not exist or could not be accessed."
}

# Tạo bucket S3 nếu chưa tồn tại
aws s3 mb s3://$s3BucketName
if ($?) {
    Write-Output "S3 bucket $s3BucketName created."
} else {
    Write-Output "Error: S3 bucket could not be created."
    exit 1
}

# Tạo tệp JSON cho bucket policy
$bucketPolicy = @'
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "PublicReadGetObject",
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::BUCKET_NAME/*"
        }
    ]
}
'@

# Thay thế BUCKET_NAME bằng tên bucket thực tế
$bucketPolicy = $bucketPolicy -replace "BUCKET_NAME", $s3BucketName

# Lưu chính sách vào tệp JSON
$policyFilePath = Join-Path -Path $PSScriptRoot -ChildPath "bucket-policy.json"
$bucketPolicy | Out-File -FilePath $policyFilePath -Encoding utf8

# Thiết lập bucket policy để cho phép public read
aws s3api put-bucket-policy --bucket $s3BucketName --policy file://$policyFilePath
if ($?) {
    Write-Output "Bucket policy set for $s3BucketName."
    # Xóa tệp JSON sau khi thiết lập thành công
    Remove-Item -Path $policyFilePath
} else {
    Write-Output "Error: Bucket policy could not be set."
    # Xóa tệp JSON nếu có lỗi
    Remove-Item -Path $policyFilePath
    exit 1
}

# Thêm thông tin bucket vào tệp .env
Add-Content $envFilePath "S3_BUCKET_NAME=$s3BucketName"

Write-Output "S3 setup completed."
