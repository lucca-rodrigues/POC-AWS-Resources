import { ZipArchive } from "archiver";
import {
	CreateFunctionCommand,
	InvokeCommand,
	UpdateFunctionCodeCommand,
	DeleteFunctionCommand,
} from "@aws-sdk/client-lambda";
import { lambdaClient } from "./floci-client.js";

// ---------------------------------------------------------------------------
// Handler da Lambda — edite aqui para estudar o comportamento da função.
// O código é empacotado em ZIP automaticamente (sem passo manual).
// ---------------------------------------------------------------------------
const HANDLER_CODE = `
exports.handler = async (event) => {
  const name = event.name || "world";
  const now = new Date().toISOString();
  return { message: \`Hello \${name}!\`, timestamp: now };
};
`;

const FUNCTION_NAME = "study-function";
const HANDLER = "index.handler";
const ROLE = "arn:aws:iam::000000000000:role/lambda-role";

// Empacota o código do handler em um ZIP em memória (buffer).
async function buildZip(code) {
	return new Promise((resolve, reject) => {
		const archive = new ZipArchive({ zlib: { level: 9 } });
		const chunks = [];

		archive.on("data", (chunk) => chunks.push(chunk));
		archive.on("error", reject);
		archive.on("end", () => resolve(Buffer.concat(chunks)));

		archive.append(code, { name: "index.js" });
		archive.finalize();
	});
}

// Cria a função Lambda a partir do ZIP.
async function createFunction(zip) {
	const result = await lambdaClient.send(
		new CreateFunctionCommand({
			FunctionName: FUNCTION_NAME,
			Handler: HANDLER,
			Role: ROLE,
			Runtime: "nodejs20.x",
			Code: { ZipFile: zip },
		}),
	);
	console.log(`[1] Função criada: ${result.FunctionArn}`);
}

// Invoca a função com um payload e imprime a resposta.
async function invoke(payload) {
	const result = await lambdaClient.send(
		new InvokeCommand({
			FunctionName: FUNCTION_NAME,
			Payload: JSON.stringify(payload),
		}),
	);
	const response = JSON.parse(Buffer.from(result.Payload).toString("utf-8"));
	console.log(`[2] Invocação (${JSON.stringify(payload)}) ->`, response);
}

// Atualiza o código da função (hot-reload) e invoca de novo.
async function updateCode(zip) {
	await lambdaClient.send(
		new UpdateFunctionCodeCommand({
			FunctionName: FUNCTION_NAME,
			ZipFile: zip,
		}),
	);
	console.log("[3] Código atualizado (hot-reload)");
}

// Deleta a função.
async function deleteFunction() {
	await lambdaClient.send(
		new DeleteFunctionCommand({ FunctionName: FUNCTION_NAME }),
	);
	console.log("[4] Função deletada");
}

async function main() {
	const zip = await buildZip(HANDLER_CODE);

	await createFunction(zip);
	await invoke({ name: "Lucas" });
	await invoke({}); // sem payload -> usa o default "world"

	// Atualiza o código para um handler diferente e invoca de novo.
	const updatedCode = `
exports.handler = async (event) => {
  const a = event.a || 0;
  const b = event.b || 0;
  return { sum: a + b };
};
`;
	await updateCode(await buildZip(updatedCode));
	await invoke({ a: 2, b: 3 });

	await deleteFunction();
	console.log("\nCiclo de vida completo da Lambda concluído!");
}

main().catch((err) => {
	console.error("Erro:", err.message);
	process.exit(1);
});
