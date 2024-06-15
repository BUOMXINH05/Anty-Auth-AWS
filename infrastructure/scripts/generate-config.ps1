Write-Output "Generating configuration files..."

# Load environment variables
./load-env.ps1

# Xác định đường dẫn chính xác tới tệp .env ở thư mục gốc
$projectRoot = (Resolve-Path -Path "$PSScriptRoot\..\..").Path
$envFilePath = Join-Path -Path $projectRoot -ChildPath ".env"

# Lấy thông tin Cognito
$cognitoUserPoolName = [System.Environment]::GetEnvironmentVariable("COGNITO_USER_POOL_NAME")
$cognitoUserPoolId = (aws cognito-idp list-user-pools --query "UserPools[?Name=='$cognitoUserPoolName'].Id" --output text)
if ($cognitoUserPoolId -ne $null) {
    Add-Content $envFilePath "COGNITO_USER_POOL_ID=$cognitoUserPoolId"
    Write-Output "Cognito User Pool ID: $cognitoUserPoolId"
} else {
    Write-Output "Error: Cognito User Pool ID could not be retrieved."
}

# Lấy thông tin Client
$cognitoClientName = [System.Environment]::GetEnvironmentVariable("COGNITO_USER_POOL_CLIENT_NAME")
$cognitoClientId = (aws cognito-idp list-user-pool-clients --user-pool-id $cognitoUserPoolId --query "UserPoolClients[?ClientName=='$cognitoClientName'].ClientId" --output text)
if ($cognitoClientId -ne $null) {
    Add-Content $envFilePath "COGNITO_CLIENT_ID=$cognitoClientId"
    Write-Output "Cognito User Pool Client ID: $cognitoClientId"
} else {
    Write-Output "Error: Cognito User Pool Client ID could not be retrieved."
}

# Lấy thông tin DynamoDB
$dynamoDbTableName = (aws dynamodb list-tables --query 'TableNames[?contains(@, `TokensTable`)]' --output text)
if ($dynamoDbTableName -ne $null) {
    Add-Content $envFilePath "DYNAMODB_TABLE_NAME=$dynamoDbTableName"
    Write-Output "DynamoDB Table Name: $dynamoDbTableName"
} else {
    Write-Output "Error: DynamoDB Table Name could not be retrieved."
}

# Lấy thông tin S3
$s3BucketName = [System.Environment]::GetEnvironmentVariable("S3_BUCKET_NAME")
if ($s3BucketName -ne $null) {
    Add-Content $envFilePath "S3_BUCKET_NAME=$s3BucketName"
    Write-Output "S3 Bucket Name: $s3BucketName"
} else {
    Write-Output "Error: S3 Bucket Name could not be retrieved."
}

Write-Output "Configuration files generated."
