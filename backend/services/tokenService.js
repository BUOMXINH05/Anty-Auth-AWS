const AWS = require('aws-sdk');
const dynamoDB = new AWS.DynamoDB.DocumentClient();

exports.getToken = async (userId) => {
    const params = {
        TableName: process.env.DYNAMODB_TABLE_NAME,
        Key: {
            UserID: userId
        }
    };
    const result = await dynamoDB.get(params).promise();
    return result.Item;
};
