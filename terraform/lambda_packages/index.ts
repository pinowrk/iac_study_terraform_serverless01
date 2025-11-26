import { APIGatewayProxyEvent, APIGatewayProxyResult } from 'aws-lambda';
import { DynamoDB } from 'aws-sdk';

const dynamodb = new DynamoDB.DocumentClient();
const TABLE_NAME = process.env.DYNAMODB_TABLE_NAME || 'todos';

export const handler = async (event: APIGatewayProxyEvent): Promise<APIGatewayProxyResult> => {
  console.log('Health check started');

  try {
    // テスト用アイテム
    const testItem = {
      userId: 'health-check',
      todoId: `test-${Date.now()}`,
      title: 'Health Check',
      status: 'active',
      createdAt: Date.now(),
      updatedAt: Date.now()
    };

    // 1. 書き込みテスト
    await dynamodb.put({
      TableName: TABLE_NAME,
      Item: testItem
    }).promise();
    console.log('✓ Write OK');

    // 2. 読み取りテスト
    const result = await dynamodb.get({
      TableName: TABLE_NAME,
      Key: {
        userId: testItem.userId,
        todoId: testItem.todoId
      }
    }).promise();
    console.log('✓ Read OK');

    // 3. 削除テスト
    await dynamodb.delete({
      TableName: TABLE_NAME,
      Key: {
        userId: testItem.userId,
        todoId: testItem.todoId
      }
    }).promise();
    console.log('✓ Delete OK');

    return {
      statusCode: 200,
      headers: {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*'
      },
      body: JSON.stringify({
        status: 'healthy',
        message: 'DynamoDB connection successful',
        tableName: TABLE_NAME,
        timestamp: new Date().toISOString(),
        tests: {
          write: 'OK',
          read: 'OK',
          delete: 'OK'
        }
      })
    };

  } catch (error) {
    console.error('Health check failed:', error);

    return {
      statusCode: 500,
      headers: {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*'
      },
      body: JSON.stringify({
        status: 'unhealthy',
        error: error instanceof Error ? error.message : 'Unknown error',
        tableName: TABLE_NAME,
        timestamp: new Date().toISOString()
      })
    };
  }
};