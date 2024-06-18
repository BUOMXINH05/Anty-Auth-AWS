Write-Output "Deploying frontend to S3..."

# Load environment variables
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$loadEnvPath = Join-Path -Path $scriptDir -ChildPath "load-env.ps1"
& $loadEnvPath

# Xác định đường dẫn chính xác tới tệp .env ở thư mục gốc
$projectRoot = (Resolve-Path -Path "$scriptDir\..\..").Path
$envFilePath = Join-Path -Path $projectRoot -ChildPath ".env"

# Lấy tên bucket từ biến môi trường
$s3BucketName = [System.Environment]::GetEnvironmentVariable("S3_BUCKET_NAME")
$awsRegion = [System.Environment]::GetEnvironmentVariable("AWS_REGION")

if ($s3BucketName -eq $null) {
    Write-Output "Error: S3 bucket name is not set in environment variables."
    exit 1
}

# Kiểm tra xem bucket đã tồn tại chưa
try {
    $bucketExists = aws s3api head-bucket --bucket $s3BucketName --region $awsRegion
    Write-Output "S3 bucket $s3BucketName exists."
} catch {
    Write-Output "S3 bucket $s3BucketName does not exist. Creating bucket..."
    $bucketCreationResponse = aws s3api create-bucket --bucket $s3BucketName --region $awsRegion --create-bucket-configuration LocationConstraint=$awsRegion
    if ($?) {
        Write-Output "S3 bucket $s3BucketName created successfully."
    } else {
        Write-Output "Error: S3 bucket $s3BucketName could not be created."
        exit 1
    }
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

$policyFilePath = Join-Path -Path $scriptDir -ChildPath "bucket-policy.json"
$bucketPolicy | Out-File -FilePath $policyFilePath -Encoding utf8

try {
    aws s3api put-bucket-policy --bucket $s3BucketName --policy file://$policyFilePath
    if ($?) {
        Write-Output "Bucket policy set for $s3BucketName."
    } else {
        Write-Output "Error: Bucket policy could not be set."
        Remove-Item -Path $policyFilePath
        exit 1
    }
} catch {
    Write-Output "Error setting bucket policy: $_"
    Remove-Item -Path $policyFilePath
    exit 1
}

# Xóa tệp chính sách sau khi thiết lập thành công
Remove-Item -Path $policyFilePath

# Tải lên các tệp frontend vào bucket S3 mà không sử dụng ACLs
try {
    $frontendPath = Join-Path -Path $projectRoot -ChildPath "frontend/public"
    aws s3 sync $frontendPath s3://$s3BucketName --region $awsRegion
    if ($?) {
        Write-Output "Frontend deployed to S3 bucket: $s3BucketName"
    } else {
        Write-Output "Error: Frontend could not be deployed to S3."
        exit 1
    }
} catch {
    Write-Output "Error uploading frontend files: $_"
    exit 1
}

Write-Output "Frontend deployment to S3 completed successfully."
