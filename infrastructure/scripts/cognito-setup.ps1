Write-Output "Setting up Cognito User Pool..."

# Load environment variables
./load-env.ps1

# Xác định đường dẫn chính xác tới tệp .env ở thư mục gốc
$projectRoot = (Resolve-Path -Path "$PSScriptRoot\..\..").Path
$envFilePath = Join-Path -Path $projectRoot -ChildPath ".env"

# Tạo User Pool
$userPoolId = (aws cognito-idp create-user-pool --pool-name "UserAuthPool" --query 'UserPool.Id' --output text)
if ($userPoolId -ne $null) {
    Add-Content $envFilePath "COGNITO_USER_POOL_ID=$userPoolId"
    Write-Output "Created Cognito User Pool with ID: $userPoolId"
} else {
    Write-Output "Error: Cognito User Pool could not be created."
    exit 1
}

# Tạo User Pool Client
$clientId = (aws cognito-idp create-user-pool-client --user-pool-id $userPoolId --client-name "UserAuthClient" --query 'UserPoolClient.ClientId' --output text)
if ($clientId -ne $null) {
    Add-Content $envFilePath "COGNITO_CLIENT_ID=$clientId"
    Write-Output "Created Cognito User Pool Client with ID: $clientId"
} else {
    Write-Output "Error: Cognito User Pool Client could not be created."
    exit 1
}
