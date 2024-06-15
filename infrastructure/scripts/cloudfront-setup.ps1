Write-Output "Setting up CloudFront distribution..."

# Load environment variables
./load-env.ps1

# Tạo CloudFront Distribution
$distributionConfig = @"
{
    "CallerReference": "my-distribution-$(Get-Random)",
    "Aliases": {
        "Quantity": 1,
        "Items": ["your-distribution-domain"]
    },
    "DefaultRootObject": "index.html",
    "Origins": {
        "Quantity": 1,
        "Items": [
            {
                "Id": "S3-origin",
                "DomainName": "your-s3-bucket.s3.amazonaws.com",
                "S3OriginConfig": {
                    "OriginAccessIdentity": ""
                }
            }
        ]
    },
    "DefaultCacheBehavior": {
        "TargetOriginId": "S3-origin",
        "ViewerProtocolPolicy": "redirect-to-https",
        "AllowedMethods": {
            "Quantity": 2,
            "Items": ["HEAD", "GET"],
            "CachedMethods": {
                "Quantity": 2,
                "Items": ["HEAD", "GET"]
            }
        },
        "ForwardedValues": {
            "QueryString": false,
            "Cookies": {
                "Forward": "none"
            },
            "Headers": {
                "Quantity": 0
            },
            "QueryStringCacheKeys": {
                "Quantity": 0
            }
        },
        "MinTTL": 0,
        "DefaultTTL": 86400,
        "MaxTTL": 31536000
    },
    "Comment": "My CloudFront distribution",
    "Enabled": true
}
"@

$distributionId = (aws cloudfront create-distribution --distribution-config "$distributionConfig" --query 'Distribution.Id' --output text)
if ($distributionId -ne $null) {
    Add-Content ../.env "CLOUDFRONT_DISTRIBUTION_ID=$distributionId"
    Write-Output "Created CloudFront distribution with ID: $distributionId"
} else {
    Write-Output "Error: CloudFront distribution could not be created."
    exit 1
}
