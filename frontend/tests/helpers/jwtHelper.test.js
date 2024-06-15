const { verifyToken, generateToken } = require('../../src/helpers/jwtHelper');
const jwt = require('jsonwebtoken');

jest.mock('jsonwebtoken');

describe('JWT Helper', () => {
    it('should verify token', () => {
        const token = 'test-token';
        jwt.verify.mockReturnValue({ userId: '123' });

        const result = verifyToken(token);

        expect(result).toEqual({ userId: '123' });
        expect(jwt.verify).toHaveBeenCalledWith(token, process.env.REACT_APP_JWT_SECRET);
    });

    it('should generate token', () => {
        const payload = { userId: '123' };
        jwt.sign.mockReturnValue('test-token');

        const result = generateToken(payload);

        expect(result).toEqual('test-token');
        expect(jwt.sign).toHaveBeenCalledWith(payload, process.env.REACT_APP_JWT_SECRET, { expiresIn: '1h' });
    });
});
