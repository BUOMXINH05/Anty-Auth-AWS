Write-Output "Setting up API Gateway..."

# Load environment variables
./load-env.ps1

# Lấy các biến môi trường
$region = [System.Environment]::GetEnvironmentVariable("AWS_REGION")
$accountId = [System.Environment]::GetEnvironmentVariable("AWS_ACCOUNT_ID")

Write-Output "Creating REST API..."
# Tạo REST API
$apiName = "UserAuthAPI"
$apiId = (aws apigateway create-rest-api --name $apiName --query 'id' --output text)
if ($apiId -ne $null) {
    Add-Content ../.env "API_ID=$apiId"
    Write-Output "Created REST API with ID: $apiId"
} else {
    Write-Output "Error: REST API could not be created."
    exit 1
}

Write-Output "Getting Root Resource ID..."
# Lấy Root Resource ID
$rootResourceId = (aws apigateway get-resources --rest-api-id $apiId --query 'items[0].id' --output text)
if ($rootResourceId -eq $null) {
    Write-Output "Error: Root Resource ID could not be retrieved."
    exit 1
}
Write-Output "Root Resource ID: $rootResourceId"

Write-Output "Creating Resource and Method for /authenticate..."
# Tạo Resource và Method cho /authenticate
$authResourceId = (aws apigateway create-resource --rest-api-id $apiId --parent-id $rootResourceId --path-part authenticate --query 'id' --output text)
if ($authResourceId -ne $null) {
    aws apigateway put-method --rest-api-id $apiId --resource-id $authResourceId --http-method POST --authorization-type NONE
    aws apigateway put-integration --rest-api-id $apiId --resource-id $authResourceId --http-method POST --type AWS_PROXY --integration-http-method POST --uri "arn:aws:apigateway:$region:lambda:path/2015-03-31/functions/arn:aws:lambda:$region:$accountId:function:AuthenticateUser/invocations"
    Write-Output "Created Resource and Method for /authenticate with Resource ID: $authResourceId"
} else {
    Write-Output "Error: Resource for /authenticate could not be created."
    exit 1
}

Write-Output "Creating Resource and Method for /refresh..."
# Tạo Resource và Method cho /refresh
$refreshResourceId = (aws apigateway create-resource --rest-api-id $apiId --parent-id $rootResourceId --path-part refresh --query 'id' --output text)
if ($refreshResourceId -ne $null) {
    aws apigateway put-method --rest-api-id $apiId --resource-id $refreshResourceId --http-method POST --authorization-type NONE
    aws apigateway put-integration --rest-api-id $apiId --resource-id $refreshResourceId --http-method POST --type AWS_PROXY --integration-http-method POST --uri "arn:aws:apigateway:$region:lambda:path/2015-03-31/functions/arn:aws:lambda:$region:$accountId:function:RefreshToken/invocations"
    Write-Output "Created Resource and Method for /refresh with Resource ID: $refreshResourceId"
} else {
    Write-Output "Error: Resource for /refresh could not be created."
    exit 1
}

Write-Output "Creating Resource and Method for /getToken..."
# Tạo Resource và Method cho /getToken
$getTokenResourceId = (aws apigateway create-resource --rest-api-id $apiId --parent-id $rootResourceId --path-part getToken --query 'id' --output text)
if ($getTokenResourceId -ne $null) {
    aws apigateway put-method --rest-api-id $apiId --resource-id $getTokenResourceId --http-method POST --authorization-type NONE
    aws apigateway put-integration --rest-api-id $apiId --resource-id $getTokenResourceId --http-method POST --type AWS_PROXY --integration-http-method POST --uri "arn:aws:apigateway:$region:lambda:path/2015-03-31/functions/arn:aws:lambda:$region:$accountId:function:GetToken/invocations"
    Write-Output "Created Resource and Method for /getToken with Resource ID: $getTokenResourceId"
} else {
    Write-Output "Error: Resource for /getToken could not be created."
    exit 1
}

Write-Output "Deploying API..."
# Triển khai API
$deploymentId = (aws apigateway create-deployment --rest-api-id $apiId --stage-name prod --query 'id' --output text)
if ($deploymentId -ne $null) {
    Add-Content ../.env "DEPLOYMENT_ID=$deploymentId"
    Write-Output "API deployed with Deployment ID: $deploymentId"
} else {
    Write-Output "Error: API could not be deployed."
    exit 1
}

Write-Output "API Gateway setup completed."
