'use strict';

// Function sqs: demonstra SQS de duas formas.
// 1. Via API Gateway: recebe { id, tipo } e ENVIA mensagem para a fila.
// 2. Via SQS trigger: a AWS invoca quando ha mensagem na fila (event.Records).

const { SQSClient, SendMessageCommand } = require('@aws-sdk/client-sqs');

const STAGE = process.env.STAGE ?? 'dev';
const SQS_QUEUE_URL = process.env.SQS_QUEUE_URL;

const sqsClient = new SQSClient({
  // De dentro do container Lambda, o floci e acessivel via AWS_ENDPOINT_URL
  // (injetado automaticamente); a QueueUrl (localhost) nao resolve.
  endpoint: process.env.AWS_ENDPOINT_URL,
  useQueueUrlAsEndpoint: false,
});

function log(message, data = {}) {
  console.log(JSON.stringify({ message, data: { ...data, stage: STAGE } }));
}

/**
 * Envia mensagens para a fila SQS e processa mensagens recebidas do trigger.
 * @param {object} event - Evento recebido (API Gateway com { id, tipo } ou SQS com Records).
 * @returns {Promise<object>} Resposta HTTP no formato proxy (statusCode, headers, body).
 */
exports.handler = async (event) => {
  // SQS trigger: processa as mensagens recebidas.
  if (event.Records) {
    const batchItemFailures = [];
    for (const record of event.Records) {
      try {
        const payload = JSON.parse(record.body);
        log('sqs.mensagem.processada', { id: payload.id, tipo: payload.tipo });
      } catch (error) {
        log('sqs.mensagem.erro', { messageId: record.messageId, erro: error.message });
        batchItemFailures.push({ itemIdentifier: record.messageId });
      }
    }
    return { batchItemFailures };
  }

  // API Gateway: envia mensagem para a fila.
  const body = JSON.parse(event.body ?? '{}');
  const { id, tipo } = body;

  await sqsClient.send(
    new SendMessageCommand({
      QueueUrl: SQS_QUEUE_URL,
      MessageBody: JSON.stringify({ id, tipo }),
    })
  );

  log('sqs.mensagem.enviada', { id, tipo });

  return {
    statusCode: 200,
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ status: 'enviado', fila: SQS_QUEUE_URL }),
  };
};
