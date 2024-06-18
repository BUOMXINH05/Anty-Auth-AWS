const jwt = require('jsonwebtoken');

exports.verifyToken = (token) => {
    try {
        return jwt.verify(token, process.env.JWT_SECRET);
    } catch (error) {
        console.error(`JWT verification error: ${error.message}`);
        throw new Error('Invalid token');
    }
};

exports.generateToken = (payload) => {
    try {
        return jwt.sign(payload, process.env.JWT_SECRET, { expiresIn: '1h' });
    } catch (error) {
        console.error(`JWT generation error: ${error.message}`);
        throw new Error('Token generation failed');
    }
};
