Write-Output "Setting up API Gateway..."

# Load environment variables
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$loadEnvPath = Join-Path -Path $scriptDir -ChildPath "load-env.ps1"
& $loadEnvPath

# Lấy các biến môi trường
$region = [System.Environment]::GetEnvironmentVariable("AWS_REGION")
$accountId = [System.Environment]::GetEnvironmentVariable("AWS_ACCOUNT_ID")

# Xác định đường dẫn tới tệp .env ở thư mục gốc
$envFilePath = Join-Path -Path $scriptDir -ChildPath "..\..\.env"

# Load API Gateway config
$configPath = Join-Path -Path $scriptDir -ChildPath "..\configs\api-gateway-config.json"
if (-Not (Test-Path $configPath)) {
    Write-Output "Error: Config file not found at $configPath"
    exit 1
}
$config = Get-Content $configPath | ConvertFrom-Json

$apiName = $config.apiName

Write-Output "Creating REST API..."
try {
    $apiId = (aws apigateway create-rest-api --name $apiName --query 'id' --output text)
    if ($apiId -ne $null) {
        Add-Content $envFilePath "`nAPI_ID=$apiId"
        Write-Output "Created REST API with ID: $apiId"
    } else {
        throw "REST API could not be created."
    }
} catch {
    Write-Output "Error: $_"
    exit 1
}

Write-Output "Getting Root Resource ID..."
try {
    $rootResourceId = (aws apigateway get-resources --rest-api-id $apiId --query 'items[0].id' --output text)
    if ($rootResourceId -eq $null) {
        throw "Root Resource ID could not be retrieved."
    }
    Write-Output "Root Resource ID: $rootResourceId"
} catch {
    Write-Output "Error: $_"
    exit 1
}

foreach ($resource in $config.resources) {
    $path = $resource.path
    $lambdaFunction = $resource.lambdaFunction

    Write-Output "Creating Resource and Method for /$path..."
    try {
        $resourceId = (aws apigateway create-resource --rest-api-id $apiId --parent-id $rootResourceId --path-part $path --query 'id' --output text)
        if ($resourceId -ne $null) {
            aws apigateway put-method --rest-api-id $apiId --resource-id $resourceId --http-method POST --authorization-type NONE
            aws apigateway put-integration --rest-api-id $apiId --resource-id $resourceId --http-method POST --type AWS_PROXY --integration-http-method POST --uri "arn:aws:apigateway:${region}:lambda:path/2015-03-31/functions/arn:aws:lambda:${region}:${accountId}:function:${lambdaFunction}/invocations"
            Write-Output "Created Resource and Method for /$path with Resource ID: $resourceId"
        } else {
            throw "Resource for /$path could not be created."
        }
    } catch {
        Write-Output "Error: $_"
        exit 1
    }
}

Write-Output "Deploying API..."
try {
    $deploymentId = (aws apigateway create-deployment --rest-api-id $apiId --stage-name prod --query 'id' --output text)
    if ($deploymentId -ne $null) {
        Add-Content $envFilePath "`nDEPLOYMENT_ID=$deploymentId"
        Write-Output "API deployed with Deployment ID: $deploymentId"
    } else {
        throw "API could not be deployed."
    }
} catch {
    Write-Output "Error: $_"
    exit 1
}

Write-Output "API Gateway setup completed."
