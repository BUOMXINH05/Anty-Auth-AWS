const { handler } = require('../handlers/getToken');
const { DynamoDBClient, GetItemCommand } = require("@aws-sdk/client-dynamodb");
const { mockClient } = require('aws-sdk-client-mock');
const { expect } = require('@jest/globals');
require('dotenv').config();

describe('Get Token Handler', () => {
    const dynamoMock = mockClient(DynamoDBClient);

    beforeEach(() => {
        dynamoMock.reset();
        process.env.DYNAMODB_TABLE_NAME = 'dummyTable';
        process.env.AWS_REGION = 'us-east-1';
        dynamoMock.on(GetItemCommand).resolves({ Item: { token: { S: 'dummyToken' } } });
    });

    afterEach(() => {
        dynamoMock.reset();
    });

    it('should get token successfully', async () => {
        const event = { pathParameters: { userId: 'dummyUserId' } };
        const result = await handler(event);
        expect(result.statusCode).toBe(200);
        expect(JSON.parse(result.body).token).toBe('dummyToken');
    });

    it('should return an error if token retrieval fails', async () => {
        dynamoMock.on(GetItemCommand).rejects(new Error('Failed to retrieve token'));

        const event = { pathParameters: { userId: 'dummyUserId' } };
        const result = await handler(event);
        expect(result.statusCode).toBe(400);
        expect(JSON.parse(result.body).message).toBe('Failed to retrieve token');
    });
});
