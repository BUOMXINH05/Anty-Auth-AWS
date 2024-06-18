Write-Output "Setting up Cognito User Pool..."

# Load environment variables
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$loadEnvPath = Join-Path -Path $scriptDir -ChildPath "load-env.ps1"
& $loadEnvPath

# Xác định đường dẫn chính xác tới tệp .env ở thư mục gốc
$projectRoot = (Resolve-Path -Path "$PSScriptRoot\..\..").Path
$envFilePath = Join-Path -Path $projectRoot -ChildPath ".env"

# Load Cognito config
$configPath = Join-Path -Path $scriptDir -ChildPath "..\configs\cognito-config.json"
if (-Not (Test-Path $configPath)) {
    Write-Output "Error: Config file not found at $configPath"
    exit 1
}
$config = Get-Content $configPath | ConvertFrom-Json

# Tạo User Pool
$userPoolName = $config.UserPoolName
$userPoolId = (aws cognito-idp create-user-pool --pool-name $userPoolName --query 'UserPool.Id' --output text)
if ($userPoolId -ne $null) {
    Add-Content $envFilePath "`nCOGNITO_USER_POOL_ID=$userPoolId"
    Write-Output "Created Cognito User Pool with ID: $userPoolId"
} else {
    Write-Output "Error: Cognito User Pool could not be created."
    exit 1
}

# Tạo User Pool Client
$clientName = $config.UserPoolClientName
$clientId = (aws cognito-idp create-user-pool-client --user-pool-id $userPoolId --client-name $clientName --query 'UserPoolClient.ClientId' --output text)
if ($clientId -ne $null) {
    Add-Content $envFilePath "`nCOGNITO_CLIENT_ID=$clientId"
    Write-Output "Created Cognito User Pool Client with ID: $clientId"
} else {
    Write-Output "Error: Cognito User Pool Client could not be created."
    exit 1
}
