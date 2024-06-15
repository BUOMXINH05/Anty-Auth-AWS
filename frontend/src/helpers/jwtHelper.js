const jwt = require('jsonwebtoken');

exports.verifyToken = (token) => {
    return jwt.verify(token, process.env.REACT_APP_JWT_SECRET);
};

exports.generateToken = (payload) => {
    return jwt.sign(payload, process.env.REACT_APP_JWT_SECRET, { expiresIn: '1h' });
};
