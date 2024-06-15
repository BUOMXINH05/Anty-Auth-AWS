const AWS = require('aws-sdk');
const cognito = new AWS.CognitoIdentityServiceProvider();

exports.authenticateWithCognito = async (username, password) => {
    const params = {
        AuthFlow: 'USER_PASSWORD_AUTH',
        ClientId: process.env.COGNITO_CLIENT_ID,
        AuthParameters: {
            USERNAME: username,
            PASSWORD: password
        }
    };
    const result = await cognito.initiateAuth(params).promise();
    return result.AuthenticationResult;
};

exports.refreshCognitoToken = async (token) => {
    const params = {
        AuthFlow: 'REFRESH_TOKEN_AUTH',
        ClientId: process.env.COGNITO_CLIENT_ID,
        AuthParameters: {
            REFRESH_TOKEN: token
        }
    };
    const result = await cognito.initiateAuth(params).promise();
    return result.AuthenticationResult;
};
