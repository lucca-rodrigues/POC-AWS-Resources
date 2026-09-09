'use strict';

const STAGE = process.env.STAGE ?? 'dev';

exports.handler = async () => ({
  statusCode: 200,
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({ status: 'ok', stage: STAGE }),
});
