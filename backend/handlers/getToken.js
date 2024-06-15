require('dotenv').config();
const { getToken } = require('../services/tokenService');
const winston = require('winston');

const logger = winston.createLogger({
    level: 'info',
    format: winston.format.json(),
    transports: [
        new winston.transports.File({ filename: 'error.log', level: 'error' }),
        new winston.transports.File({ filename: 'combined.log' }),
    ],
});

exports.handler = async (event) => {
    try {
        const { userId } = JSON.parse(event.body);
        const result = await getToken(userId);
        return {
            statusCode: 200,
            body: JSON.stringify(result),
        };
    } catch (error) {
        logger.error(`Get token error: ${error.message}`);
        return {
            statusCode: 400,
            body: JSON.stringify({ message: error.message }),
        };
    }
};
