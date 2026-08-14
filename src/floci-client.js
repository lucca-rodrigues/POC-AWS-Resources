import { S3Client } from "@aws-sdk/client-s3";
import { LambdaClient } from "@aws-sdk/client-lambda";
import { EC2Client } from "@aws-sdk/client-ec2";

const ENDPOINT = process.env.FLOCI_ENDPOINT || "http://localhost:4566";
const REGION = process.env.AWS_REGION || "us-east-1";
const ACCESS_KEY = process.env.AWS_ACCESS_KEY_ID || "test";
const SECRET_KEY = process.env.AWS_SECRET_ACCESS_KEY || "test";

const baseConfig = {
	endpoint: ENDPOINT,
	region: REGION,
	credentials: {
		accessKeyId: ACCESS_KEY,
		secretAccessKey: SECRET_KEY,
	},
};

export const s3Client = new S3Client({ ...baseConfig, forcePathStyle: true });
export const lambdaClient = new LambdaClient(baseConfig);
export const ec2Client = new EC2Client(baseConfig);
