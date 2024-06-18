const { authenticateWithCognito, refreshCognitoToken } = require('../../utils/cognitoUtils');
const { CognitoIdentityProviderClient, InitiateAuthCommand } = require("@aws-sdk/client-cognito-identity-provider");
const { mockClient } = require('aws-sdk-client-mock');
const { expect } = require('@jest/globals');
require('dotenv').config();

describe('Cognito Utils', () => {
    const cognitoMock = mockClient(CognitoIdentityProviderClient);

    beforeEach(() => {
        cognitoMock.reset();
        process.env.COGNITO_CLIENT_ID = 'dummyClientId';
        process.env.AWS_REGION = 'us-east-1';
    });

    it('should authenticate with Cognito successfully', async () => {
        cognitoMock.on(InitiateAuthCommand).resolves({
            AuthenticationResult: { AccessToken: 'dummyAccessToken' }
        });

        const result = await authenticateWithCognito('testuser', 'testpassword');
        expect(result).toEqual({ AccessToken: 'dummyAccessToken' });
    });

    it('should throw an error if authentication fails', async () => {
        cognitoMock.on(InitiateAuthCommand).rejects(new Error('Authentication failed'));

        await expect(authenticateWithCognito('invaliduser', 'invalidpassword')).rejects.toThrow('Authentication failed');
    });

    it('should refresh Cognito token successfully', async () => {
        cognitoMock.on(InitiateAuthCommand).resolves({
            AuthenticationResult: { AccessToken: 'newDummyAccessToken' }
        });

        const result = await refreshCognitoToken('dummyRefreshToken');
        expect(result).toEqual({ AccessToken: 'newDummyAccessToken' });
    });

    it('should throw an error if token refresh fails', async () => {
        cognitoMock.on(InitiateAuthCommand).rejects(new Error('Token refresh failed'));

        await expect(refreshCognitoToken('invalidRefreshToken')).rejects.toThrow('Token refresh failed');
    });
});
