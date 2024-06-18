Write-Output "Starting cleanup of AWS resources..."

# Load environment variables
./load-env.ps1

function Get-EnvVar($name) {
    return [System.Environment]::GetEnvironmentVariable($name)
}

function Delete-Resource($resourceName, $deleteCommand) {
    try {
        Invoke-Expression $deleteCommand
        Write-Output "Deleted $resourceName"
    } catch {
        Write-Output "Error deleting $resourceName: $_"
    }
}

# Delete CloudFront distribution
$cloudfrontDistributionId = Get-EnvVar "CLOUDFRONT_DISTRIBUTION_ID"
if ($cloudfrontDistributionId) {
    Delete-Resource "CloudFront distribution: $cloudfrontDistributionId" "aws cloudfront update-distribution --id $cloudfrontDistributionId --distribution-config file://disable-distribution-config.json; aws cloudfront delete-distribution --id $cloudfrontDistributionId"
}

# Delete S3 bucket
$s3BucketName = Get-EnvVar "S3_BUCKET_NAME"
if ($s3BucketName) {
    Delete-Resource "S3 bucket: $s3BucketName" "aws s3 rb s3://$s3BucketName --force"
}

# Delete DynamoDB table
$dynamoDbTableName = Get-EnvVar "DYNAMODB_TABLE_NAME"
if ($dynamoDbTableName) {
    Delete-Resource "DynamoDB table: $dynamoDbTableName" "aws dynamodb delete-table --table-name $dynamoDbTableName"
}

# Delete Cognito user pool and client
$cognitoUserPoolId = Get-EnvVar "COGNITO_USER_POOL_ID"
$cognitoClientId = Get-EnvVar "COGNITO_CLIENT_ID"
if ($cognitoUserPoolId) {
    if ($cognitoClientId) {
        Delete-Resource "Cognito user pool client: $cognitoClientId" "aws cognito-idp delete-user-pool-client --user-pool-id $cognitoUserPoolId --client-id $cognitoClientId"
    }
    Delete-Resource "Cognito user pool: $cognitoUserPoolId" "aws cognito-idp delete-user-pool --user-pool-id $cognitoUserPoolId"
}

# Delete API Gateway
$apiId = Get-EnvVar "API_ID"
if ($apiId) {
    Delete-Resource "API Gateway: $apiId" "aws apigateway delete-rest-api --rest-api-id $apiId"
}

# Delete Lambda functions
$lambdaFunctions = @("AuthenticateUser", "RefreshToken", "GetToken")
foreach ($functionName in $lambdaFunctions) {
    Delete-Resource "Lambda function: $functionName" "aws lambda delete-function --function-name $functionName"
}

Write-Output "Cleanup completed."
