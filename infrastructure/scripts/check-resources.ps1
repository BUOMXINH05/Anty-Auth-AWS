Write-Output "Checking AWS resources..."

# Xác định đường dẫn chính xác tới tệp load-env.ps1
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$loadEnvPath = Join-Path -Path $scriptDir -ChildPath "load-env.ps1"

# Load environment variables
& $loadEnvPath

$resources = @(
    @{
        Name = "Cognito resources"
        Command = "aws cognito-idp list-user-pools --max-results 10"
    },
    @{
        Name = "DynamoDB resources"
        Command = "aws dynamodb list-tables"
    },
    @{
        Name = "S3 buckets"
        Command = "aws s3 ls"
    },
    @{
        Name = "Lambda functions"
        Command = "aws lambda list-functions"
    },
    @{
        Name = "CloudFront distributions"
        Command = "aws cloudfront list-distributions"
    }
)

foreach ($resource in $resources) {
    try {
        Write-Output "Checking $($resource.Name)..."
        Invoke-Expression $resource.Command
    } catch {
        Write-Output "Error checking $($resource.Name): $_"
    }
}

Write-Output "Check completed."
