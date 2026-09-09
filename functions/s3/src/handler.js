'use strict';

const { S3Client, PutObjectCommand, GetObjectCommand } = require('@aws-sdk/client-s3');

const STAGE = process.env.STAGE ?? 'dev';
const S3_BUCKET = process.env.S3_BUCKET;

const s3Client = new S3Client({});

function log(message, data = {}) {
  console.log(JSON.stringify({ message, data: { ...data, stage: STAGE } }));
}

/**
 * Salva um objeto no S3 e retorna o objeto lido.
 * @param {object} event - Evento recebido do API Gateway com { id, conteudo } no body.
 * @returns {Promise<object>} Resposta HTTP no formato proxy (statusCode, headers, body).
 */
exports.handler = async (event) => {
  const body = JSON.parse(event.body ?? '{}');
  const { id, conteudo } = body;
  const key = `s3/${id}.json`;

  await s3Client.send(
    new PutObjectCommand({
      Bucket: S3_BUCKET,
      Key: key,
      Body: JSON.stringify({ id, conteudo, criadoEm: new Date().toISOString() }),
    })
  );

  const response = await s3Client.send(
    new GetObjectCommand({ Bucket: S3_BUCKET, Key: key })
  );
  const objeto = JSON.parse(await response.Body.transformToString());

  log('s3.objeto.salvo', { id, key });

  return {
    statusCode: 200,
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ objeto, key }),
  };
};
