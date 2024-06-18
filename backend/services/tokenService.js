const { DynamoDBClient, GetItemCommand } = require("@aws-sdk/client-dynamodb");

const getToken = async (userId) => {
    const client = new DynamoDBClient({ region: process.env.AWS_REGION });
    const params = {
        TableName: process.env.DYNAMODB_TABLE_NAME,
        Key: { userId: { S: userId } }
    };
    try {
        const command = new GetItemCommand(params);
        const result = await client.send(command);
        return result.Item;
    } catch (error) {
        console.error(`Get token error: ${error.message}`);
        throw new Error('Failed to retrieve token');
    }
};

module.exports = { getToken };
