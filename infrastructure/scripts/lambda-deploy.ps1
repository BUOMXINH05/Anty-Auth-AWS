Write-Output "Deploying Lambda functions..."

# Load environment variables
./load-env.ps1

# Lấy các biến môi trường
$region = [System.Environment]::GetEnvironmentVariable("AWS_REGION")
$accountId = [System.Environment]::GetEnvironmentVariable("AWS_ACCOUNT_ID")
$lambdaRoleArn = "arn:aws:iam::$accountId:role/your-lambda-role"

# Đóng gói và triển khai hàm authenticate
zip -j authenticate.zip ./backend/handlers/authenticate.js
aws lambda create-function --function-name AuthenticateUser --zip-file fileb://authenticate.zip --handler authenticate.handler --runtime nodejs14.x --role $lambdaRoleArn
if ($?) {
    Write-Output "Deployed Lambda function: AuthenticateUser"
} else {
    Write-Output "Error: Lambda function AuthenticateUser could not be deployed."
    exit 1
}

# Đóng gói và triển khai hàm refresh
zip -j refresh.zip ./backend/handlers/refresh.js
aws lambda create-function --function-name RefreshToken --zip-file fileb://refresh.zip --handler refresh.handler --runtime nodejs14.x --role $lambdaRoleArn
if ($?) {
    Write-Output "Deployed Lambda function: RefreshToken"
} else {
    Write-Output "Error: Lambda function RefreshToken could not be deployed."
    exit 1
}

# Đóng gói và triển khai hàm getToken
zip -j getToken.zip ./backend/handlers/getToken.js
aws lambda create-function --function-name GetToken --zip-file fileb://getToken.zip --handler getToken.handler --runtime nodejs14.x --role $lambdaRoleArn
if ($?) {
    Write-Output "Deployed Lambda function: GetToken"
} else {
    Write-Output "Error: Lambda function GetToken could not be deployed."
    exit 1
}

# Tạo các quyền truy cập API Gateway cho các hàm Lambda
aws lambda add-permission --function-name AuthenticateUser --statement-id apigateway-access --action lambda:InvokeFunction --principal apigateway.amazonaws.com --source-arn arn:aws:execute-api:$region:$accountId:*
aws lambda add-permission --function-name RefreshToken --statement-id apigateway-access --action lambda:InvokeFunction --principal apigateway.amazonaws.com --source-arn arn:aws:execute-api:$region:$accountId:*
aws lambda add-permission --function-name GetToken --statement-id apigateway-access --action lambda:InvokeFunction --principal apigateway.amazonaws.com --source-arn arn:aws:execute-api:$region:$accountId:*
if ($?) {
    Write-Output "API Gateway permissions added for Lambda functions."
} else {
    Write-Output "Error: API Gateway permissions could not be added."
    exit 1
}

Write-Output "Lambda functions deployed."
