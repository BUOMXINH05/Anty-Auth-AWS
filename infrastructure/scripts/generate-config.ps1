Write-Output "Generating configuration files..."

# Load environment variables
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$loadEnvPath = Join-Path -Path $scriptDir -ChildPath "load-env.ps1"
& $loadEnvPath

# Xác định đường dẫn chính xác tới tệp .env ở thư mục gốc
$projectRoot = (Resolve-Path -Path "$scriptDir\..\..").Path
$envFilePath = Join-Path -Path $projectRoot -ChildPath ".env"

# Load generate config
$configPath = Join-Path -Path $scriptDir -ChildPath "..\configs\generate-config.json"
if (-Not (Test-Path $configPath)) {
    Write-Output "Error: Config file not found at $configPath"
    exit 1
}
$config = Get-Content $configPath | ConvertFrom-Json

# Lấy thông tin Cognito
$cognitoUserPoolName = $config.cognitoUserPoolName
$cognitoUserPoolId = (aws cognito-idp list-user-pools --query "UserPools[?Name=='$cognitoUserPoolName'].Id" --output text)
if ($cognitoUserPoolId -ne "") {
    Add-Content $envFilePath "COGNITO_USER_POOL_ID=$cognitoUserPoolId"
    Write-Output "Cognito User Pool ID: $cognitoUserPoolId"
} else {
    Write-Output "Error: Cognito User Pool ID could not be retrieved."
    exit 1
}

# Lấy thông tin Client
$cognitoClientName = $config.cognitoClientName
$cognitoClientId = (aws cognito-idp list-user-pool-clients --user-pool-id $cognitoUserPoolId --query "UserPoolClients[?ClientName=='$cognitoClientName'].ClientId" --output text)
if ($cognitoClientId -ne "") {
    Add-Content $envFilePath "COGNITO_CLIENT_ID=$cognitoClientId"
    Write-Output "Cognito User Pool Client ID: $cognitoClientId"
} else {
    Write-Output "Error: Cognito User Pool Client ID could not be retrieved."
    exit 1
}

# Lấy thông tin DynamoDB
$dynamoDbTableName = $config.dynamoDbTableName
$dynamoDbTableExists = (aws dynamodb list-tables --query "TableNames" --output text | Select-String -Pattern $dynamoDbTableName)
if ($dynamoDbTableExists) {
    Add-Content $envFilePath "DYNAMODB_TABLE_NAME=$dynamoDbTableName"
    Write-Output "DynamoDB Table Name: $dynamoDbTableName"
} else {
    Write-Output "Error: DynamoDB Table Name could not be retrieved."
    exit 1
}

# Lấy thông tin S3
$s3BucketName = $config.s3BucketName
try {
    aws s3api head-bucket --bucket $s3BucketName > $null 2>&1
    Add-Content $envFilePath "S3_BUCKET_NAME=$s3BucketName"
    Write-Output "S3 Bucket Name: $s3BucketName"
} catch {
    Write-Output "Error: S3 Bucket Name could not be retrieved."
    exit 1
}

Write-Output "Configuration files generated."
