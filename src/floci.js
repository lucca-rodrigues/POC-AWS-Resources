// ===========================================================================
// CLI — CRIA, PUBLICA E ACESSA UMA LAMBDA NO FLOCI
// ---------------------------------------------------------------------------
// Simula o fluxo real de deploy do AWS SAM dentro do floci:
//   empacotar código -> upload p/ S3 -> criar stack CloudFormation
//   (floci expande o transform SAM) -> invocar Lambda -> deletar stack.
// Espelha o que `sam package` + `sam deploy` fazem na AWS real.
//
// Uso:
//   node src/floci.js deploy   -> cria e publica a Lambda (mantém no ar)
//   node src/floci.js invoke   -> acessa (invoca) a Lambda já publicada
//   node src/floci.js delete   -> limpa (deleta a stack e o S3)
// ===========================================================================

import {
	CloudFormationClient,
	CreateStackCommand,
	DescribeStacksCommand,
	DeleteStackCommand,
	DescribeStackResourcesCommand,
} from "@aws-sdk/client-cloudformation";
import {
	S3Client,
	CreateBucketCommand,
	PutObjectCommand,
	DeleteObjectCommand,
	DeleteBucketCommand,
} from "@aws-sdk/client-s3";
import { LambdaClient, InvokeCommand, CreateFunctionUrlConfigCommand, GetFunctionUrlConfigCommand } from "@aws-sdk/client-lambda";
import fs from "fs";
import path from "path";
import { fileURLToPath } from "url";
import "dotenv/config";
import { buildZipFromDir } from "./resources/lambda-zip.js";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const APP_DIR = path.resolve(__dirname, "app");
const TEMPLATE_PATH = path.join(APP_DIR, "template.yaml");
const SRC_DIR = path.join(APP_DIR, "src");

const ENDPOINT = process.env.FLOCI_ENDPOINT || "http://localhost:4566";
const REGION = process.env.AWS_REGION || "us-east-1";
const ACCESS_KEY = process.env.AWS_ACCESS_KEY_ID || "test";
const SECRET_KEY = process.env.AWS_SECRET_ACCESS_KEY || "test";

const STACK_NAME = "sam-study";
const BUCKET = "sam-study-bucket";
const ZIP_KEY = "function.zip";

const baseConfig = {
	endpoint: ENDPOINT,
	region: REGION,
	credentials: { accessKeyId: ACCESS_KEY, secretAccessKey: SECRET_KEY },
};

const cfn = new CloudFormationClient(baseConfig);
const s3 = new S3Client({ ...baseConfig, forcePathStyle: true });
const lambda = new LambdaClient(baseConfig);

// Cria o bucket S3 se ainda não existir.
async function ensureBucket() {
	try {
		await s3.send(new CreateBucketCommand({ Bucket: BUCKET }));
		console.log(`[1] Bucket S3 criado: ${BUCKET}`);
	} catch (err) {
		if (err.name === "BucketAlreadyOwnedByYou") {
			console.log(`[1] Bucket S3 já existe: ${BUCKET}`);
		} else {
			throw err;
		}
	}
}

// Empacota o código e envia o ZIP para o S3.
async function uploadCode() {
	const zip = await buildZipFromDir(SRC_DIR);
	await s3.send(
		new PutObjectCommand({
			Bucket: BUCKET,
			Key: ZIP_KEY,
			Body: zip,
		}),
	);
	console.log(`[2] Código empacotado e enviado: s3://${BUCKET}/${ZIP_KEY}`);
}

// Lê o template SAM e aponta o CodeUri para o ZIP no S3 (como o `sam package`).
function buildTemplateBody() {
	const template = fs.readFileSync(TEMPLATE_PATH, "utf-8");
	return template.replace(
		"CodeUri: src/",
		`CodeUri: s3://${BUCKET}/${ZIP_KEY}`,
	);
}

// Cria a stack CloudFormation (floci expande o transform SAM).
async function createStack() {
	await cfn.send(
		new CreateStackCommand({
			StackName: STACK_NAME,
			TemplateBody: buildTemplateBody(),
			Capabilities: ["CAPABILITY_IAM"],
		}),
	);
	console.log(`[3] Stack criada: ${STACK_NAME} (aguardando CREATE_COMPLETE...)`);
}

// Aguarda a stack terminar de criar.
async function waitForStack() {
	for (let i = 0; i < 30; i++) {
		const { Stacks } = await cfn.send(
			new DescribeStacksCommand({ StackName: STACK_NAME }),
		);
		const status = Stacks[0].StackStatus;
		if (status === "CREATE_COMPLETE") {
			console.log(`[4] Stack pronta (${status})`);
			return;
		}
		if (status.endsWith("_FAILED") || status.endsWith("_ROLLBACK_COMPLETE")) {
			throw new Error(`Stack falhou: ${status}`);
		}
		await new Promise((r) => setTimeout(r, 2000));
	}
	throw new Error("Timeout aguardando a stack");
}

// Descobre o nome real da Lambda criada pela stack.
async function findFunctionName() {
	const { StackResources } = await cfn.send(
		new DescribeStackResourcesCommand({ StackName: STACK_NAME }),
	);
	const fn = StackResources.find(
		(r) => r.ResourceType === "AWS::Lambda::Function",
	);
	if (!fn) throw new Error("Lambda não encontrada na stack");
	return fn.PhysicalResourceId;
}

// Busca (ou cria) a URL pública da função e devolve o endpoint HTTP.
// O floci ignora o FunctionUrlConfig do template SAM, então criamos a URL
// explicitamente via API (o mesmo que `aws lambda create-function-url-config`).
async function getFunctionUrl(functionName) {
	try {
		const { FunctionUrl } = await lambda.send(
			new CreateFunctionUrlConfigCommand({
				FunctionName: functionName,
				AuthType: "NONE",
			}),
		);
		return FunctionUrl;
	} catch (err) {
		if (err.name === "ResourceConflictException") {
			const { FunctionUrl } = await lambda.send(
				new GetFunctionUrlConfigCommand({ FunctionName: functionName }),
			);
			return FunctionUrl;
		}
		throw err;
	}
}

// Invoca a Lambda com um payload e imprime a resposta.
async function invoke(functionName) {
	const result = await lambda.send(
		new InvokeCommand({
			FunctionName: functionName,
			Payload: JSON.stringify({ name: "Lucas" }),
		}),
	);
	const response = JSON.parse(Buffer.from(result.Payload).toString("utf-8"));
	console.log(`-> ${functionName} respondeu:`, response);
	return response;
}

// Ação 1: cria e publica a Lambda, mantendo-a no ar.
async function deploy() {
	await ensureBucket();
	await uploadCode();
	await createStack();
	await waitForStack();
	const functionName = await findFunctionName();
	const url = await getFunctionUrl(functionName);
	const response = await invoke(functionName);
	console.log(
		`\n✅ Lambda publicada e no ar! Nome: ${functionName}\n` +
			`   Acesse (invocar): npm run floci:invoke\n` +
			`   Navegador (URL):  ${url}\n` +
			`   Limpe com:        npm run floci:delete\n` +
			`   Resposta:         ${JSON.stringify(response.body || response)}`,
	);
}

// Ação 2: acessa (invoca) a Lambda já publicada.
async function access() {
	const functionName = await findFunctionName();
	const response = await invoke(functionName);
	console.log(
		`\n✅ Lambda ${functionName} acessada!\n` +
			`   Resposta:   ${JSON.stringify(response.body || response)}`,
	);
}

// Ação 3: limpa (deleta a stack e o S3).
async function deleteStack() {
	await cfn.send(new DeleteStackCommand({ StackName: STACK_NAME }));
	console.log("[6] Stack deletada");

	await s3.send(new DeleteObjectCommand({ Bucket: BUCKET, Key: ZIP_KEY }));
	await s3.send(new DeleteBucketCommand({ Bucket: BUCKET }));
	console.log("[7] S3 limpo");
	console.log("\n✅ Ambiente limpo!");
}

const ACTIONS = {
	deploy,
	invoke: access,
	delete: deleteStack,
};

const action = process.argv[2];
if (!ACTIONS[action]) {
	console.error("Uso: node src/floci.js <deploy|invoke|delete>");
	process.exit(1);
}

ACTIONS[action]().catch((err) => {
	console.error("Erro:", err.message);
	process.exit(1);
});
