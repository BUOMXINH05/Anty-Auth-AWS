Write-Output "Starting cleanup of AWS resources..."

# Load environment variables
./load-env.ps1

function Get-EnvVar($name) {
    return [System.Environment]::GetEnvironmentVariable($name)
}

# Delete CloudFront distribution
$cloudfrontDistributionId = Get-EnvVar "CLOUDFRONT_DISTRIBUTION_ID"
if ($cloudfrontDistributionId) {
    aws cloudfront update-distribution --id $cloudfrontDistributionId --distribution-config file://disable-distribution-config.json
    aws cloudfront delete-distribution --id $cloudfrontDistributionId
    Write-Output "Deleted CloudFront distribution: $cloudfrontDistributionId"
}

# Delete S3 bucket
$s3BucketName = Get-EnvVar "S3_BUCKET_NAME"
if ($s3BucketName) {
    aws s3 rb s3://$s3BucketName --force
    Write-Output "Deleted S3 bucket: $s3BucketName"
}

# Delete DynamoDB table
$dynamoDbTableName = Get-EnvVar "DYNAMODB_TABLE_NAME"
if ($dynamoDbTableName) {
    aws dynamodb delete-table --table-name $dynamoDbTableName
    Write-Output "Deleted DynamoDB table: $dynamoDbTableName"
}

# Delete Cognito user pool and client
$cognitoUserPoolId = Get-EnvVar "COGNITO_USER_POOL_ID"
$cognitoClientId = Get-EnvVar "COGNITO_CLIENT_ID"
if ($cognitoUserPoolId) {
    if ($cognitoClientId) {
        aws cognito-idp delete-user-pool-client --user-pool-id $cognitoUserPoolId --client-id $cognitoClientId
        Write-Output "Deleted Cognito user pool client: $cognitoClientId"
    }
    aws cognito-idp delete-user-pool --user-pool-id $cognitoUserPoolId
    Write-Output "Deleted Cognito user pool: $cognitoUserPoolId"
}

# Delete API Gateway
$apiId = Get-EnvVar "API_ID"
if ($apiId) {
    aws apigateway delete-rest-api --rest-api-id $apiId
    Write-Output "Deleted API Gateway: $apiId"
}

# Delete Lambda functions
$lambdaFunctions = @("AuthenticateUser", "RefreshToken", "GetToken")
foreach ($functionName in $lambdaFunctions) {
    aws lambda delete-function --function-name $functionName
    Write-Output "Deleted Lambda function: $functionName"
}

Write-Output "Cleanup completed."
