const { handler } = require('../handlers/refresh');
const AWS = require('aws-sdk-mock');
const jwt = require('jsonwebtoken');
const { expect } = require('chai');
require('dotenv').config();

const { JWT_SECRET } = process.env;

describe('Refresh Token Handler', () => {
  beforeEach(() => {
    AWS.mock('DynamoDB.DocumentClient', 'get', (params, callback) => {
      callback(null, { Item: { UserID: 'testuser', Token: 'test-refresh-token' } });
    });
  });

  afterEach(() => {
    AWS.restore('DynamoDB.DocumentClient');
  });

  it('should return new token on successful refresh', async () => {
    const refreshToken = jwt.sign({ username: 'testuser' }, JWT_SECRET);
    const event = {
      body: JSON.stringify({ refreshToken }),
    };
    const response = await handler(event);
    const body = JSON.parse(response.body);
    expect(response.statusCode).to.equal(200);
    expect(body.token).to.exist;
  });

  it('should return error on invalid refresh token', async () => {
    const event = {
      body: JSON.stringify({ refreshToken: 'invalid-token' }),
    };
    const response = await handler(event);
    const body = JSON.parse(response.body);
    expect(response.statusCode).to.equal(400);
    expect(body.error).to.exist;
  });
});
