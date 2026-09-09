'use strict';

const STAGE = process.env.STAGE ?? 'dev';

/**
 * Responde requisicoes HTTP com base no path e method recebidos.
 * @param {object} event - Evento recebido do API Gateway.
 * @returns {Promise<object>} Resposta HTTP no formato proxy (statusCode, headers, body).
 */
exports.handler = async () => ({
  statusCode: 200,
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({ status: 'ok', stage: STAGE }),
});
