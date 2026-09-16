'use strict';

const { DynamoDBClient, PutItemCommand } = require('@aws-sdk/client-dynamodb');

const TABLE = process.env.STEPS_TABLE;
const STEP = 'gerar-token';

const dynamo = new DynamoDBClient({});

/**
 * Gera o invitation token e registra o step no DynamoDB.
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

  const token = `tok_${jornada_id}`;
  return { jornada_id, step: STEP, status: 'ok', token };
};
