Write-Output "Deploying frontend to S3..."

# Load environment variables
./load-env.ps1

# Xác định đường dẫn chính xác tới tệp .env ở thư mục gốc
$projectRoot = (Resolve-Path -Path "$PSScriptRoot\..\..").Path
$envFilePath = Join-Path -Path $projectRoot -ChildPath ".env"

# Lấy tên bucket từ biến môi trường
$s3BucketName = [System.Environment]::GetEnvironmentVariable("S3_BUCKET_NAME")
if ($s3BucketName -eq $null) {
    Write-Output "Error: S3 bucket name is not set in environment variables."
    exit 1
}

# Tạo bucket S3 nếu chưa tồn tại
aws s3 mb s3://$s3BucketName
if ($?) {
    Write-Output "S3 bucket $s3BucketName created or already exists."
} else {
    Write-Output "Error: S3 bucket could not be created."
    exit 1
}

# Thiết lập bucket policy để cho phép public read
$bucketPolicy = @"
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "PublicReadGetObject",
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::$s3BucketName/*"
        }
    ]
}
"@

aws s3api put-bucket-policy --bucket $s3BucketName --policy $bucketPolicy
if ($?) {
    Write-Output "Bucket policy set for $s3BucketName."
} else {
    Write-Output "Error: Bucket policy could not be set."
    exit 1
}

# Tải lên các tệp frontend
aws s3 sync "$PSScriptRoot/../../frontend/public" s3://$s3BucketName --acl public-read
if ($?) {
    Write-Output "Frontend deployed to S3 bucket: $s3BucketName"
} else {
    Write-Output "Error: Frontend could not be deployed to S3."
    exit 1
}
