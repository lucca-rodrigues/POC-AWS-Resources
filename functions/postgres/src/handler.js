'use strict';

const { Client } = require('pg');
const { SecretsManagerClient, GetSecretValueCommand } = require('@aws-sdk/client-secrets-manager');

const STAGE = process.env.STAGE ?? 'dev';
const SECRET_NAME = process.env.SECRET_NAME;

const secretsClient = new SecretsManagerClient({});
let configCache = null;
let pgClient = null;

function log(message, data = {}) {
  console.log(JSON.stringify({ message, data: { ...data, stage: STAGE } }));
}

/**
 * Converte connection string para o formato URI do node-postgres.
 * @param {string} npgsql - Connection string no formato .NET.
 * @returns {string} URI postgres://user:pass@host:port/db.
 */
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

async function getPgClient() {
  if (pgClient) return pgClient;
  const config = await getConfig();
  pgClient = new Client({ connectionString: toPgConnectionString(config.Database.ConnectionString) });
  await pgClient.connect();
  return pgClient;
}

/**
 * Salva um registro no Postgres e retorna o registro criado.
 * @param {object} event - Evento recebido do API Gateway com { id, nome } no body.
 * @returns {Promise<object>} Resposta HTTP no formato proxy (statusCode, headers, body).
 */
exports.handler = async (event) => {
  const body = JSON.parse(event.body ?? '{}');
  const { id, nome } = body;

  const client = await getPgClient();
  await client.query(`
    CREATE TABLE IF NOT EXISTS postgres_itens (
      id TEXT PRIMARY KEY,
      nome TEXT NOT NULL,
      criado_em TIMESTAMPTZ NOT NULL DEFAULT now()
    )
  `);
  await client.query(
    'INSERT INTO postgres_itens (id, nome) VALUES ($1, $2) ON CONFLICT (id) DO NOTHING',
    [id, nome]
  );
  const result = await client.query('SELECT * FROM postgres_itens WHERE id = $1', [id]);

  log('postgres.item.salvo', { id, nome });

  return {
    statusCode: 200,
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ registro: result.rows[0] }),
  };
};
