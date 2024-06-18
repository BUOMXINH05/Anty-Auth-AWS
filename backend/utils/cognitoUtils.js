const { CognitoIdentityProviderClient, InitiateAuthCommand } = require("@aws-sdk/client-cognito-identity-provider");

const authenticateWithCognito = async (username, password) => {
    const client = new CognitoIdentityProviderClient();
    const params = {
        AuthFlow: "USER_PASSWORD_AUTH",
        ClientId: process.env.COGNITO_CLIENT_ID,
        AuthParameters: {
            USERNAME: username,
            PASSWORD: password
        }
    };
    try {
        const command = new InitiateAuthCommand(params);
        const response = await client.send(command);
        return response.AuthenticationResult;
    } catch (error) {
        console.error(`Cognito authentication error: ${error.message}`);
        throw new Error('Authentication failed');
    }
};

const refreshCognitoToken = async (refreshToken) => {
    const client = new CognitoIdentityProviderClient();
    const params = {
        AuthFlow: "REFRESH_TOKEN_AUTH",
        ClientId: process.env.COGNITO_CLIENT_ID,
        AuthParameters: {
            REFRESH_TOKEN: refreshToken
        }
    };
    try {
        const command = new InitiateAuthCommand(params);
        const response = await client.send(command);
        return response.AuthenticationResult;
    } catch (error) {
        console.error(`Cognito refresh token error: ${error.message}`);
        throw new Error('Token refresh failed');
    }
};

module.exports = {
    authenticateWithCognito,
    refreshCognitoToken
};
