const { authenticateWithCognito, refreshCognitoToken } = require('../utils/cognitoUtils');

exports.authenticateUser = async (username, password) => {
    return await authenticateWithCognito(username, password);
};

exports.refreshToken = async (token) => {
    return await refreshCognitoToken(token);
};
