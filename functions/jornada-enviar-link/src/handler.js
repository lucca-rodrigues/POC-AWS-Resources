'use strict';

const { DynamoDBClient, PutItemCommand } = require('@aws-sdk/client-dynamodb');

const TABLE = process.env.STEPS_TABLE;
const STEP = 'enviar-link';

const dynamo = new DynamoDBClient({});

/**
 * Envia link via Zenvia (mock) e registra o step no DynamoDB.
 * @param {object} event - Evento recebido do Step Functions com { jornada_id }.
 * @returns {Promise<object>} Resultado do step.
 */
exports.handler = async (event) => {
  const { jornada_id } = event;
  // Mock da integracao Zenvia (SDK real: lib NPM)
  const mensagem_id = `msg_${jornada_id}`;
  await dynamo.send(new PutItemCommand({
    TableName: TABLE,
    Item: {
      jornada_id: { S: jornada_id },
      step: { S: STEP },
      status: { S: 'ok' },
      recebido_em: { S: new Date().toISOString() },
    },
  }));

  return { jornada_id, step: STEP, status: 'ok', mensagem_id };
};
