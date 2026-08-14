// ===========================================================================
// CÓDIGO REAL DA LAMBDA (CommonJS, como roda na AWS)
// ---------------------------------------------------------------------------
// Este arquivo é empacotado pelo `sam build` e enviado para a Lambda.
// O handler recebe o `event` (payload da invocação) e retorna a resposta.
// ===========================================================================

exports.handler = async (event) => {
	const name = event.name || "world";
	const now = new Date().toISOString();
	const stage = process.env.STAGE || "dev";

	return {
		statusCode: 200,
		headers: { "content-type": "application/json" },
		body: JSON.stringify({
			message: `Hello ${name}!`,
			timestamp: now,
			stage,
		}),
	};
};
