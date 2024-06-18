const { getToken } = require('../services/tokenService');
const { DynamoDBClient, GetItemCommand } = require("@aws-sdk/client-dynamodb");
const { mockClient } = require('aws-sdk-client-mock');
const { expect } = require('@jest/globals');
require('dotenv').config();

describe('Token Service', () => {
    const dynamoMock = mockClient(DynamoDBClient);

    beforeEach(() => {
        dynamoMock.reset();
        process.env.DYNAMODB_TABLE_NAME = 'dummyTable';
        process.env.AWS_REGION = 'us-east-1';
        dynamoMock.on(GetItemCommand).resolves({ Item: { token: 'dummyToken' } });
    });

    it('should get token successfully', async () => {
        const result = await getToken('dummyUserId');
        expect(result).toEqual({ token: 'dummyToken' });
    });
});
