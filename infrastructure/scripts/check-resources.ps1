Write-Output "Checking AWS resources..."

# Load environment variables
./load-env.ps1

Write-Output "Checking Cognito resources..."
# Kiểm tra Cognito
aws cognito-idp list-user-pools --max-results 10

Write-Output "Checking DynamoDB resources..."
# Kiểm tra DynamoDB
aws dynamodb list-tables

Write-Output "Checking S3 buckets..."
# Kiểm tra S3
aws s3 ls

Write-Output "Checking Lambda functions..."
# Kiểm tra Lambda
aws lambda list-functions

Write-Output "Checking CloudFront distributions..."
# Kiểm tra CloudFront
aws cloudfront list-distributions

Write-Output "Check completed."
