const { handler } = require('../handlers/getToken');
const AWS = require('aws-sdk-mock');
const { expect } = require('chai');

describe('Get Token Handler', () => {
  beforeEach(() => {
    AWS.mock('DynamoDB.DocumentClient', 'get', (params, callback) => {
      callback(null, { Item: { UserID: 'testuser', Token: 'test-token' } });
    });
  });

  afterEach(() => {
    AWS.restore('DynamoDB.DocumentClient');
  });

  it('should return token if found', async () => {
    const event = {
      body: JSON.stringify({ userId: 'testuser' }),
    };
    const response = await handler(event);
    const body = JSON.parse(response.body);
    expect(response.statusCode).to.equal(200);
    expect(body.token).to.exist;
  });

  it('should return 404 if token not found', async () => {
    AWS.remock('DynamoDB.DocumentClient', 'get', (params, callback) => {
      callback(null, {});
    });
    const event = {
      body: JSON.stringify({ userId: 'unknownuser' }),
    };
    const response = await handler(event);
    const body = JSON.parse(response.body);
    expect(response.statusCode).to.equal(404);
    expect(body.error).to.exist;
  });
});
