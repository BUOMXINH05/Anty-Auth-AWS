const { authenticateWithCognito, refreshCognitoToken } = require('../utils/cognitoUtils');

exports.authenticateUser = async (username, password) => {
    try {
        return await authenticateWithCognito(username, password);
    } catch (error) {
        console.error(`Authentication error: ${error.message}`);
        throw new Error('Authentication failed');
    }
};

exports.refreshToken = async (token) => {
    try {
        return await refreshCognitoToken(token);
    } catch (error) {
        console.error(`Refresh token error: ${error.message}`);
        throw new Error('Token refresh failed');
    }
};
