'use strict';

const { DynamoDBClient, PutItemCommand } = require('@aws-sdk/client-dynamodb');
const { SecretsManagerClient, GetSecretValueCommand } = require('@aws-sdk/client-secrets-manager');

const TABLE = process.env.STEPS_TABLE;
const SECRET_NAME = process.env.SECRET_NAME;
const STEP = 'enviar-link';

const dynamo = new DynamoDBClient({});
const secretsClient = new SecretsManagerClient({});

let configCache = null;

async function getConfig() {
  if (configCache) return configCache;
  const response = await secretsClient.send(
    new GetSecretValueCommand({ SecretId: SECRET_NAME })
  );
  configCache = JSON.parse(response.SecretString);
  return configCache;
}

/**
 * Envia link via Zenvia (mock) e registra o step no DynamoDB.
 * Credenciais da Zenvia lidas do Secrets Manager (padrao da org).
 * @param {object} event - Evento recebido do Step Functions com { jornada_id }.
 * @returns {Promise<object>} Resultado do step.
 */
exports.handler = async (event) => {
  const { jornada_id } = event;

  // Credenciais da Zenvia via Secrets Manager (nao hardcoded).
  const config = await getConfig();
  const { BaseUrl, ApiToken } = config.Zenvia;
  const mensagem_id = `msg_${jornada_id}`;

  console.log(JSON.stringify({
    message: 'zenvia.link.enviado',
    data: { jornada_id, baseUrl: BaseUrl, tokenMasked: ApiToken.slice(0, 4) + '***' },
  }));

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
