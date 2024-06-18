const { handler } = require('../handlers/authenticate');
const { CognitoIdentityProviderClient, InitiateAuthCommand } = require("@aws-sdk/client-cognito-identity-provider");
const { mockClient } = require('aws-sdk-client-mock');
const { expect } = require('@jest/globals');
require('dotenv').config();

describe('Authenticate Handler', () => {
    const cognitoMock = mockClient(CognitoIdentityProviderClient);

    beforeEach(() => {
        cognitoMock.reset();
        process.env.COGNITO_CLIENT_ID = 'dummyClientId';
        process.env.AWS_REGION = 'us-east-1';
        cognitoMock.on(InitiateAuthCommand).resolves({
            AuthenticationResult: { AccessToken: 'dummyAccessToken' }
        });
    });

    afterEach(() => {
        cognitoMock.reset();
    });

    it('should authenticate user successfully', async () => {
        const event = { body: JSON.stringify({ username: 'testuser', password: 'testpassword' }) };
        const result = await handler(event);
        expect(result.statusCode).toBe(200);
        expect(JSON.parse(result.body).AccessToken).toBe('dummyAccessToken');
    });

    it('should return an error if authentication fails', async () => {
        cognitoMock.on(InitiateAuthCommand).rejects(new Error('Authentication failed'));

        const event = { body: JSON.stringify({ username: 'invaliduser', password: 'invalidpassword' }) };
        const result = await handler(event);
        expect(result.statusCode).toBe(400);
        expect(JSON.parse(result.body).message).toBe('Authentication failed');
    });
});
