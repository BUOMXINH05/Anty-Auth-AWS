const { handler } = require('../handlers/authenticate');
const AWS = require('aws-sdk-mock');
const { expect } = require('chai');

describe('Authenticate Handler', () => {
  beforeEach(() => {
    AWS.mock('CognitoIdentityServiceProvider', 'initiateAuth', (params, callback) => {
      callback(null, { AuthenticationResult: { AccessToken: 'test-token' } });
    });
  });

  afterEach(() => {
    AWS.restore('CognitoIdentityServiceProvider');
  });

  it('should return token on successful authentication', async () => {
    const event = {
      body: JSON.stringify({ username: 'testuser', password: 'testpassword' }),
    };
    const response = await handler(event);
    const body = JSON.parse(response.body);
    expect(response.statusCode).to.equal(200);
    expect(body.token).to.exist;
  });

  it('should return error on failed authentication', async () => {
    AWS.remock('CognitoIdentityServiceProvider', 'initiateAuth', (params, callback) => {
      callback(new Error('Invalid credentials'));
    });
    const event = {
      body: JSON.stringify({ username: 'testuser', password: 'wrongpassword' }),
    };
    const response = await handler(event);
    const body = JSON.parse(response.body);
    expect(response.statusCode).to.equal(400);
    expect(body.error).to.exist;
  });
});
