Write-Output "Deploying Lambda functions..."

# Load environment variables
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$loadEnvPath = Join-Path -Path $scriptDir -ChildPath "load-env.ps1"
& $loadEnvPath

# Lấy các biến môi trường
$region = [System.Environment]::GetEnvironmentVariable("AWS_REGION")
$accountId = [System.Environment]::GetEnvironmentVariable("AWS_ACCOUNT_ID")
$lambdaRoleArn = [System.Environment]::GetEnvironmentVariable("LAMBDA_ROLE_ARN")

# Kiểm tra biến môi trường lambdaRoleArn
if (-not $lambdaRoleArn) {
    Write-Output "Error: LAMBDA_ROLE_ARN is not set in environment variables."
    exit 1
}

# Load Lambda config
$configPath = Join-Path -Path $scriptDir -ChildPath "..\configs\lambda-config.json"
if (-Not (Test-Path $configPath)) {
    Write-Output "Error: Config file not found at $configPath"
    exit 1
}
$config = Get-Content $configPath | ConvertFrom-Json

# Đường dẫn tới các tệp JavaScript
$authenticateJsPath = Join-Path -Path $scriptDir -ChildPath "..\..\backend\handlers\authenticate.js"
$refreshJsPath = Join-Path -Path $scriptDir -ChildPath "..\..\backend\handlers\refresh.js"
$getTokenJsPath = Join-Path -Path $scriptDir -ChildPath "..\..\backend\handlers\getToken.js"
$lambdaEdgeHandlerPath = Join-Path -Path $scriptDir -ChildPath "lambda-edge-handler.js"

# Kiểm tra sự tồn tại của các tệp JavaScript
if (-Not (Test-Path $authenticateJsPath)) {
    Write-Output "Error: File not found at $authenticateJsPath"
    exit 1
}
if (-Not (Test-Path $refreshJsPath)) {
    Write-Output "Error: File not found at $refreshJsPath"
    exit 1
}
if (-Not (Test-Path $getTokenJsPath)) {
    Write-Output "Error: File not found at $getTokenJsPath"
    exit 1
}
if (-Not (Test-Path $lambdaEdgeHandlerPath)) {
    Write-Output "Error: File not found at $lambdaEdgeHandlerPath"
    exit 1
}

# Đóng gói và triển khai hàm authenticate
$zipFile = Join-Path -Path $scriptDir -ChildPath "authenticate.zip"
Remove-Item $zipFile -ErrorAction SilentlyContinue
Compress-Archive -Path $authenticateJsPath -DestinationPath $zipFile
if (-Not (Test-Path $zipFile)) {
    Write-Output "Error: Failed to create zip file $zipFile"
    exit 1
}
aws lambda create-function --function-name AuthenticateUser --zip-file fileb://$zipFile --handler $config.LambdaHandler --runtime nodejs20.x --role $lambdaRoleArn --environment Variables="{S3BucketName=$($config.S3BucketName),LambdaZipFile=$($config.LambdaZipFile)}"
if ($?) {
    Write-Output "Deployed Lambda function: AuthenticateUser"
} else {
    Write-Output "Error: Lambda function AuthenticateUser could not be deployed."
    exit 1
}

# Đóng gói và triển khai hàm refresh
$zipFile = Join-Path -Path $scriptDir -ChildPath "refresh.zip"
Remove-Item $zipFile -ErrorAction SilentlyContinue
Compress-Archive -Path $refreshJsPath -DestinationPath $zipFile
if (-Not (Test-Path $zipFile)) {
    Write-Output "Error: Failed to create zip file $zipFile"
    exit 1
}
aws lambda create-function --function-name RefreshToken --zip-file fileb://$zipFile --handler refresh.handler --runtime nodejs20.x --role $lambdaRoleArn
if ($?) {
    Write-Output "Deployed Lambda function: RefreshToken"
} else {
    Write-Output "Error: Lambda function RefreshToken could not be deployed."
    exit 1
}

# Đóng gói và triển khai hàm getToken
$zipFile = Join-Path -Path $scriptDir -ChildPath "getToken.zip"
Remove-Item $zipFile -ErrorAction SilentlyContinue
Compress-Archive -Path $getTokenJsPath -DestinationPath $zipFile
if (-Not (Test-Path $zipFile)) {
    Write-Output "Error: Failed to create zip file $zipFile"
    exit 1
}
aws lambda create-function --function-name GetToken --zip-file fileb://$zipFile --handler getToken.handler --runtime nodejs20.x --role $lambdaRoleArn
if ($?) {
    Write-Output "Deployed Lambda function: GetToken"
} else {
    Write-Output "Error: Lambda function GetToken could not be deployed."
    exit 1
}

# Tạo các quyền truy cập API Gateway cho các hàm Lambda
aws lambda add-permission --function-name AuthenticateUser --statement-id apigateway-access --action lambda:InvokeFunction --principal apigateway.amazonaws.com --source-arn arn:aws:execute-api:${region}:${accountId}:*
aws lambda add-permission --function-name RefreshToken --statement-id apigateway-access --action lambda:InvokeFunction --principal apigateway.amazonaws.com --source-arn arn:aws:execute-api:${region}:${accountId}:*
aws lambda add-permission --function-name GetToken --statement-id apigateway-access --action lambda:InvokeFunction --principal apigateway.amazonaws.com --source-arn arn:aws:execute-api:${region}:${accountId}:*
if ($?) {
    Write-Output "API Gateway permissions added for Lambda functions."
} else {
    Write-Output "Error: API Gateway permissions could not be added."
    exit 1
}

Write-Output "Lambda functions deployed."

# Deploy Lambda@Edge function
Write-Output "Deploying Lambda@Edge function..."

# Tạo tệp ZIP cho Lambda@Edge
$zipFile = Join-Path -Path $scriptDir -ChildPath "lambda-edge-handler.zip"
Remove-Item $zipFile -ErrorAction SilentlyContinue
Compress-Archive -Path $lambdaEdgeHandlerPath -DestinationPath $zipFile

# Tạo hàm Lambda@Edge
$createFunctionOutput = aws lambda create-function --function-name InsertJavaScriptLambdaEdge `
    --runtime nodejs20.x `
    --role $lambdaRoleArn `
    --handler lambda-edge-handler.handler `
    --zip-file fileb://$zipFile `
    --region us-east-1

if ($createFunctionOutput -eq $null) {
    Write-Output "Error: Failed to create Lambda function InsertJavaScriptLambdaEdge"
    exit 1
} else {
    Write-Output "Successfully created Lambda function InsertJavaScriptLambdaEdge"
}

# Triển khai Lambda@Edge
$functionArn = aws lambda publish-version --function-name InsertJavaScriptLambdaEdge --query 'FunctionArn' --output text

# Tạo tệp cấu hình CloudFront
$configContent = @"
{
  "CallerReference": "my-distribution",
  "Aliases": {
    "Quantity": 0,
    "Items": []
  },
  "DefaultRootObject": "index.html",
  "Origins": {
    "Quantity": 1,
    "Items": [
      {
        "Id": "S3-Origin",
        "DomainName": "anty-auth-frontend-bucket.s3.amazonaws.com",
        "OriginPath": "",
        "CustomHeaders": {
          "Quantity": 0,
          "Items": []
        },
        "S3OriginConfig": {
          "OriginAccessIdentity": ""
        }
      }
    ]
  },
  "DefaultCacheBehavior": {
    "TargetOriginId": "S3-Origin",
    "ViewerProtocolPolicy": "redirect-to-https",
    "AllowedMethods": {
      "Quantity": 2,
      "Items": [
        "HEAD",
        "GET"
      ],
      "CachedMethods": {
        "Quantity": 2,
        "Items": [
          "HEAD",
          "GET"
        ]
      }
    },
    "Compress": true,
    "LambdaFunctionAssociations": {
      "Quantity": 1,
      "Items": [
        {
          "LambdaFunctionARN": "$functionArn",
          "EventType": "viewer-response",
          "IncludeBody": true
        }
      ]
    }
  },
  "Comment": "",
  "Enabled": true,
  "ViewerCertificate": {
    "CloudFrontDefaultCertificate": true,
    "MinimumProtocolVersion": "TLSv1",
    "CertificateSource": "cloudfront"
  }
}
"@

# Lưu cấu hình vào tệp
$configFilePath = Join-Path -Path $scriptDir -ChildPath "distribution-config.json"
$configContent | Out-File -FilePath $configFilePath -Encoding utf8

# Triển khai CloudFront với Lambda@Edge
$distributionOutput = aws cloudfront create-distribution-with-lambda-edge --distribution-config file://$configFilePath

if ($distributionOutput -eq $null) {
    Write-Output "Error: Failed to create CloudFront distribution with Lambda@Edge"
    exit 1
} else {
    Write-Output "Successfully created CloudFront distribution with Lambda@Edge"
}

# Xóa tệp tạm thời
Remove-Item -Path $configFilePath -Force
Remove-Item -Path $zipFile -Force
