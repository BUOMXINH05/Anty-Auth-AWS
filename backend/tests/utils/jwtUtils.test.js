const { verifyToken, generateToken } = require('../../utils/jwtUtils');
const jwt = require('jsonwebtoken');
const sinon = require('sinon');

describe('JWT Utils', () => {
    let jwtSignStub, jwtVerifyStub;

    beforeEach(() => {
        jwtSignStub = sinon.stub(jwt, 'sign');
        jwtVerifyStub = sinon.stub(jwt, 'verify');
    });

    afterEach(() => {
        jwtSignStub.restore();
        jwtVerifyStub.restore();
    });

    it('should generate a token successfully', () => {
        const payload = { userId: 'testuser' };
        const mockToken = 'dummyToken';
        jwtSignStub.returns(mockToken);

        const token = generateToken(payload);
        expect(token).toBe(mockToken);
    });

    it('should throw an error if token generation fails', () => {
        jwtSignStub.throws(new Error('Token generation failed'));

        expect(() => generateToken({ userId: 'testuser' })).toThrow('Token generation failed');
    });

    it('should verify a token successfully', () => {
        const mockToken = 'dummyToken';
        const mockPayload = { userId: 'testuser' };
        jwtVerifyStub.returns(mockPayload);

        const payload = verifyToken(mockToken);
        expect(payload).toEqual(mockPayload);
    });

    it('should throw an error if token verification fails', () => {
        jwtVerifyStub.throws(new Error('Invalid token'));

        expect(() => verifyToken('invalidToken')).toThrow('Invalid token');
    });
});
