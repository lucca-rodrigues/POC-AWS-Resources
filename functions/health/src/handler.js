'use strict';

const STAGE = process.env.STAGE ?? 'dev';

/**
 * Handler da Lambda.
 * @param {object} event - Evento recebido (API Gateway).
 * @returns {Promise<object>} Resposta HTTP no formato proxy.
 */
exports.handler = async () => ({
  statusCode: 200,
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({ status: 'ok', stage: STAGE }),
});
