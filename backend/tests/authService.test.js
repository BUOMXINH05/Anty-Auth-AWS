const { authenticateUser, refreshToken } = require('../services/authService');
const { CognitoIdentityProviderClient, InitiateAuthCommand, AdminInitiateAuthCommand } = require("@aws-sdk/client-cognito-identity-provider");
const { mockClient } = require('aws-sdk-client-mock');
const { expect } = require('@jest/globals');
require('dotenv').config();

describe('Auth Service', () => {
    const cognitoMock = mockClient(CognitoIdentityProviderClient);

    beforeEach(() => {
        cognitoMock.reset();
        process.env.COGNITO_CLIENT_ID = 'dummyClientId';
        process.env.AWS_REGION = 'us-east-1';
    });

    it('should authenticate user successfully', async () => {
        cognitoMock.on(InitiateAuthCommand).resolves({
            AuthenticationResult: { AccessToken: 'dummyAccessToken' }
        });

        const result = await authenticateUser('testuser', 'testpassword');
        expect(result).toEqual({ AccessToken: 'dummyAccessToken' });
    });

    it('should refresh token successfully', async () => {
        cognitoMock.on(AdminInitiateAuthCommand).resolves({
            AuthenticationResult: { AccessToken: 'newDummyAccessToken' }
        });

        const result = await refreshToken('dummyRefreshToken');
        expect(result).toEqual({ AccessToken: 'newDummyAccessToken' });
    });
});
