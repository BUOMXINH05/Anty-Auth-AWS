const { handler } = require('../handlers/refresh');
const { CognitoIdentityProviderClient, AdminInitiateAuthCommand } = require("@aws-sdk/client-cognito-identity-provider");
const { mockClient } = require('aws-sdk-client-mock');
const { expect } = require('@jest/globals');
require('dotenv').config();

describe('Refresh Token Handler', () => {
    const cognitoMock = mockClient(CognitoIdentityProviderClient);

    beforeEach(() => {
        cognitoMock.reset();
        process.env.COGNITO_CLIENT_ID = 'dummyClientId';
        process.env.AWS_REGION = 'us-east-1';
    });

    it('should refresh token successfully', async () => {
        cognitoMock.on(AdminInitiateAuthCommand).resolves({
            AuthenticationResult: { AccessToken: 'newDummyAccessToken' }
        });

        const event = { body: JSON.stringify({ refreshToken: 'dummyRefreshToken' }) };
        const result = await handler(event);
        expect(result.statusCode).toBe(200);
        expect(JSON.parse(result.body).AccessToken).toBe('newDummyAccessToken');
    });

    it('should return an error if token refresh fails', async () => {
        cognitoMock.on(AdminInitiateAuthCommand).rejects(new Error('Token refresh failed'));

        const event = { body: JSON.stringify({ refreshToken: 'dummyRefreshToken' }) };
        const result = await handler(event);
        expect(result.statusCode).toBe(400);
        expect(JSON.parse(result.body).message).toBe('Token refresh failed');
    });
});
