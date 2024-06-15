const { getToken } = require('../../src/services/tokenService');

global.fetch = jest.fn(() =>
    Promise.resolve({
        ok: true,
        json: () => Promise.resolve({ token: 'test-token' }),
    })
);

describe('Token Service', () => {
    it('should get token from server', async () => {
        const userId = 'user123';
        const token = await getToken(userId);

        expect(token).toEqual('test-token');
        expect(fetch).toHaveBeenCalledWith(
            `${process.env.REACT_APP_API_BASE_URL}/getToken`,
            expect.objectContaining({
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ userId }),
            })
        );
    });
});
