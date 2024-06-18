Write-Output "Setting up DynamoDB table..."

# Xác định đường dẫn chính xác tới tệp load-env.ps1
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$loadEnvPath = Join-Path -Path $scriptDir -ChildPath "load-env.ps1"
# Đường dẫn đúng tới tệp .env trong thư mục gốc (hai cấp so với thư mục script)
$envFilePath = Join-Path -Path $scriptDir -ChildPath "..\..\.env"

# Load environment variables
& $loadEnvPath

# Load DynamoDB config
$configPath = Join-Path -Path $scriptDir -ChildPath "..\configs\dynamodb-config.json"
if (-Not (Test-Path $configPath)) {
    Write-Output "Error: Config file not found at $configPath"
    exit 1
}
$config = Get-Content $configPath | ConvertFrom-Json

# Chuyển đổi cấu hình DynamoDB sang định dạng JSON
$attributeDefinitions = ($config.AttributeDefinitions | ConvertTo-Json -Compress).Replace('"', '\"')
$keySchema = ($config.KeySchema | ConvertTo-Json -Compress).Replace('"', '\"')
$provisionedThroughput = ($config.ProvisionedThroughput | ConvertTo-Json -Compress).Replace('"', '\"')

# Tạo bảng DynamoDB
$tableName = $config.TableName
$tableArn = (aws dynamodb create-table --table-name $tableName --attribute-definitions "$attributeDefinitions" --key-schema "$keySchema" --provisioned-throughput "$provisionedThroughput" --query 'TableDescription.TableArn' --output text)
if ($tableArn -ne $null -and $tableArn -ne "") {
    Add-Content $envFilePath "`nDYNAMODB_TABLE_NAME=$tableName"
    Write-Output "Created DynamoDB table with ARN: $tableArn"
} else {
    Write-Output "Error: DynamoDB table could not be created."
    exit 1
}
