import "dotenv/config";
import express from "express";
import {
	ListBucketsCommand,
	CreateBucketCommand,
	PutObjectCommand,
	GetObjectCommand,
} from "@aws-sdk/client-s3";
import { CreateFunctionCommand, InvokeCommand } from "@aws-sdk/client-lambda";
import { DescribeInstancesCommand } from "@aws-sdk/client-ec2";
import { s3Client, lambdaClient, ec2Client } from "./floci-client.js";

const app = express();
app.use(express.json());

const PORT = process.env.PORT || 3000;

// ---- S3 ----

app.get("/s3/buckets", async (_req, res) => {
	try {
		const { Buckets } = await s3Client.send(new ListBucketsCommand({}));
		res.json({ buckets: Buckets?.map((b) => b.Name) ?? [] });
	} catch (err) {
		res.status(500).json({ error: err.message });
	}
});

app.post("/s3/bucket", async (req, res) => {
	try {
		const { bucket } = req.body;
		if (!bucket) return res.status(400).json({ error: "bucket is required" });
		await s3Client.send(new CreateBucketCommand({ Bucket: bucket }));
		res.json({ created: bucket });
	} catch (err) {
		res.status(500).json({ error: err.message });
	}
});

app.post("/s3/upload", async (req, res) => {
	try {
		const { bucket, key, body } = req.body;
		if (!bucket || !key || body === undefined) {
			return res
				.status(400)
				.json({ error: "bucket, key and body are required" });
		}
		await s3Client.send(
			new PutObjectCommand({ Bucket: bucket, Key: key, Body: body }),
		);
		res.json({ uploaded: { bucket, key } });
	} catch (err) {
		res.status(500).json({ error: err.message });
	}
});

app.get("/s3/object/:bucket/:key", async (req, res) => {
	try {
		const { bucket, key } = req.params;
		const { Body } = await s3Client.send(
			new GetObjectCommand({ Bucket: bucket, Key: key }),
		);
		const content = await Body.transformToString();
		res.json({ bucket, key, content });
	} catch (err) {
		res.status(500).json({ error: err.message });
	}
});

// ---- Lambda ----

app.post("/lambda/function", async (req, res) => {
	try {
		const { name, handler, role, code } = req.body;
		if (!name || !handler || !role || !code) {
			return res
				.status(400)
				.json({ error: "name, handler, role and code are required" });
		}
		const result = await lambdaClient.send(
			new CreateFunctionCommand({
				FunctionName: name,
				Handler: handler,
				Role: role,
				Runtime: "nodejs20.x",
				Code: { ZipFile: Buffer.from(code, "base64") },
			}),
		);
		res.json({ functionArn: result.FunctionArn });
	} catch (err) {
		res.status(500).json({ error: err.message });
	}
});

app.post("/lambda/invoke", async (req, res) => {
	try {
		const { name, payload } = req.body;
		if (!name) return res.status(400).json({ error: "name is required" });
		const result = await lambdaClient.send(
			new InvokeCommand({
				FunctionName: name,
				Payload: JSON.stringify(payload ?? {}),
			}),
		);
		const response = JSON.parse(Buffer.from(result.Payload).toString("utf-8"));
		res.json({ statusCode: result.StatusCode, response });
	} catch (err) {
		res.status(500).json({ error: err.message });
	}
});

// ---- EC2 ----

app.get("/ec2/instances", async (_req, res) => {
	try {
		const { Reservations } = await ec2Client.send(
			new DescribeInstancesCommand({}),
		);
		const instances =
			Reservations?.flatMap((r) => r.Instances ?? []).map((i) => ({
				instanceId: i.InstanceId,
				state: i.State?.Name,
				type: i.InstanceType,
			})) ?? [];
		res.json({ instances });
	} catch (err) {
		res.status(500).json({ error: err.message });
	}
});

app.listen(PORT, () => {
	console.log(`Floci bridge server running on http://localhost:${PORT}`);
});
