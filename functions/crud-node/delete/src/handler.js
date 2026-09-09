'use strict';

// CRUD - Delete: remove um registro do Postgres usando TypeORM.
// Recebe { id } via API Gateway e retorna o resultado.

const { DataSource } = require('typeorm');
const { SecretsManagerClient, GetSecretValueCommand } = require('@aws-sdk/client-secrets-manager');
const { Item } = require('./entity');

const STAGE = process.env.STAGE ?? 'dev';
const SECRET_NAME = process.env.SECRET_NAME;

const secretsClient = new SecretsManagerClient({});
let configCache = null;
let dataSource = null;

function log(message, data = {}) {
  console.log(JSON.stringify({ message, data: { ...data, stage: STAGE } }));
}

function toPgConnectionString(npgsql) {
  const parts = Object.fromEntries(
    npgsql.split(';').map((part) => part.trim().split('='))
  );
  const host = parts.Host ?? parts.host;
  const port = parts.Port ?? parts.port ?? '5432';
  const database = parts.Database ?? parts.database;
  const user = parts.Username ?? parts.username;
  const password = parts.Password ?? parts.password;
  return `postgres://${encodeURIComponent(user)}:${encodeURIComponent(password)}@${host}:${port}/${database}`;
}

async function getConfig() {
  if (configCache) return configCache;
  const response = await secretsClient.send(
    new GetSecretValueCommand({ SecretId: SECRET_NAME })
  );
  configCache = JSON.parse(response.SecretString);
  return configCache;
}

async function getDataSource() {
  if (dataSource?.isInitialized) return dataSource;
  const config = await getConfig();
  dataSource = new DataSource({
    type: 'postgres',
    url: toPgConnectionString(config.Database.ConnectionString),
    entities: [Item],
    synchronize: true,
  });
  await dataSource.initialize();
  return dataSource;
}

/**
 * Remove um registro do Postgres usando TypeORM.
 * @param {object} event - Evento recebido do API Gateway com { id } no body.
 * @returns {Promise<object>} Resposta HTTP no formato proxy (statusCode, headers, body).
 */
exports.handler = async (event) => {
  const body = JSON.parse(event.body ?? '{}');
  const { id } = body;

  const ds = await getDataSource();
  const repository = ds.getRepository('Item');

  const result = await repository.delete({ id });

  log('crud.item.removido', { id, afetados: result.affected ?? 0 });

  return {
    statusCode: 200,
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ removido: (result.affected ?? 0) > 0, id }),
  };
};
