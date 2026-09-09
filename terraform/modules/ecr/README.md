# Modulo `ecr`

Provisiona um repositorio **Amazon ECR** (`aws_ecr_repository`) para hospedar imagens
de container — no caso deste projeto, a imagem da Lambda (`Futuro.CoreBancario.Clientes.Api`).

Funciona contra a AWS real e contra o **ministack** (emulador local).

## Uso

```hcl
module "ecr" {
  source = "./modules/ecr"

  repository_name = "corebancario-cliente-lambda"
}
```

## Inputs

| Nome | Tipo | Default | Descricao |
|------|------|---------|-----------|
| `repository_name` | string | — | Nome do repositorio ECR. |
| `image_tag_mutability` | string | `MUTABLE` | `MUTABLE` ou `IMMUTABLE`. |
| `scan_on_push` | bool | `true` | Scan de vulnerabilidades no push. |
| `force_delete` | bool | `true` | Permite destruir o repo com imagens dentro. |

## Outputs

| Nome | Descricao |
|------|-----------|
| `repository_url` | URL usada no `docker push`/`pull`. |
| `repository_arn` | ARN do repositorio. |
| `repository_name` | Nome do repositorio. |
| `registry_id` | ID do registry (conta). |
