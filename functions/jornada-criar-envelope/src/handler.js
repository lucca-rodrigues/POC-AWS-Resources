'use strict';

const { DynamoDBClient, PutItemCommand } = require('@aws-sdk/client-dynamodb');

const TABLE = process.env.STEPS_TABLE;
const STEP = 'criar-envelope';

const dynamo = new DynamoDBClient({});

/**
 * Cria envelope na Click Sign (mock) e registra o step no DynamoDB.
 * @param {object} event - Evento recebido do Step Functions com { jornada_id }.
 * @returns {Promise<object>} Resultado do step.
 */
exports.handler = async (event) => {
  const { jornada_id } = event;
  // Mock da integracao Click Sign (SDK real: lib NPM)
  const envelope_id = `env_${jornada_id}`;
  await dynamo.send(new PutItemCommand({
    TableName: TABLE,
    Item: {
      jornada_id: { S: jornada_id },
      step: { S: STEP },
      status: { S: 'ok' },
      recebido_em: { S: new Date().toISOString() },
    },
  }));

  return { jornada_id, step: STEP, status: 'ok', envelope_id };
};
