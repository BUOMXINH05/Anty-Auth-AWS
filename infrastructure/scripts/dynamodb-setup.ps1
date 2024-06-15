Write-Output "Setting up DynamoDB table..."

# Load environment variables
./load-env.ps1

# Tạo bảng DynamoDB
$tableName = "TokensTable"
$tableArn = (aws dynamodb create-table --table-name $tableName --attribute-definitions AttributeName=UserId,AttributeType=S --key-schema AttributeName=UserId,KeyType=HASH --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 --query 'TableDescription.TableArn' --output text)
if ($tableArn -ne $null) {
    Add-Content ../.env "DYNAMODB_TABLE_NAME=$tableName"
    Write-Output "Created DynamoDB table with ARN: $tableArn"
} else {
    Write-Output "Error: DynamoDB table could not be created."
    exit 1
}
