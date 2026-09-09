'use strict';

// Function HTTP de exemplo (referencia)
// Tipo: http

const STAGE = process.env.STAGE ?? 'dev';

function log(message, data = {}) {
  console.log(JSON.stringify({ message, data: { ...data, stage: STAGE } }));
}

// HTTP: rota de API — responde com base no path/method recebidos.
exports.handler = async (event) => {
  try {
    const path = event.rawPath ?? event.path ?? '/';
    const method = event.requestContext?.http?.method ?? event.httpMethod ?? 'GET';

    log('exemplo-http.requisicao', { path, method });

    return {
      statusCode: 200,
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ message: 'ok', path, method, stage: STAGE }),
    };
  } catch (error) {
    log('exemplo-http.erro', { erro: error.message });
    return {
      statusCode: 500,
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ erro: 'erro interno' }),
    };
  }
};


