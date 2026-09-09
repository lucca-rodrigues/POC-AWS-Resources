# Módulo S3

Bucket S3 para armazenamento de artefatos.

## Uso

```hcl
module "s3" {
  source = "../../modules/s3"

  bucket_name = "futurosign-artefatos"
}
```

## Recursos

- `aws_s3_bucket.this` — bucket
- `aws_s3_bucket_versioning.this` — versionamento (opcional)

## Outputs

- `bucket_name` — nome do bucket
- `bucket_arn` — ARN do bucket
