'use strict';

const { DynamoDBClient, PutItemCommand } = require('@aws-sdk/client-dynamodb');

const TABLE = process.env.STEPS_TABLE;
const STEP = 'atualizar-status';

const dynamo = new DynamoDBClient({});

/**
 * Atualiza o status da jornada e registra o step no DynamoDB.
 * @param {object} event - Evento recebido do Step Functions com { jornada_id }.
 * @returns {Promise<object>} Resultado do step.
 */
exports.handler = async (event) => {
  const { jornada_id } = event;

  await dynamo.send(new PutItemCommand({
    TableName: TABLE,
    Item: {
      jornada_id: { S: jornada_id },
      step: { S: STEP },
      status: { S: 'ok' },
      recebido_em: { S: new Date().toISOString() },
    },
  }));

  return { jornada_id, step: STEP, status: 'link_enviado' };
};
