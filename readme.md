# POC AWS Lambda — padrão Futuro (Terraform + floci)

POC de **monorepo de functions Lambda** seguindo o padrão de infra do time de
arquitetura: Terraform com módulos reutilizáveis, Lambda como **container
image (ECR)** e API Gateway REST. O ambiente local é simulado com o **floci**
(emulador AWS via Docker) — sem custo e sem feature gates, espelhando o fluxo
real de produção.

> **Fidelidade:** os arquivos de `terraform/` (módulos, providers, versions,
> .gitignore) seguem o padrão real da organização — zero impacto no
> desenvolvimento e na publicação em prod.

---

## Pré-requisitos

| Ferramenta          | Versão mínima              | Como verificar      |
| ------------------- | -------------------------- | ------------------- |
| Docker (Compose)    | 20+                        | `docker --version`  |
| Terraform           | 1.5+                       | `terraform version` |
| Node.js             | 22 (imagem base da Lambda) | `node --version`    |

> O **AWS CLI não é necessário** — o deploy usa Terraform + Docker.

---

## Setup passo a passo

```bash
# 1. Clone o projeto
git clone <url-do-repo> && cd aws

# 2. Sobe o emulador floci (Docker)
docker compose up -d

# 3. Deploy: build das functions + terraform apply (cria ECR, Lambdas, API Gateway, Secrets)
npm run deploy

# 4. Invoca as rotas via API Gateway
npm run invoke

# 5. (Opcional) Limpa o ambiente quando terminar
cd terraform/environments/dev-local && terraform destroy -auto-approve
```

Saída esperada do invoke:

```
== GET /health (function health) ==
{"status":"ok","stage":"dev"}
== GET /ping (function ping) ==
{"message":"pong","stage":"dev"}
```

---

## Estrutura

```
pocs/aws/
├── functions/                  # MONOREPO de functions Lambda
│   ├── health/                 # function: GET /health
│   │   ├── Dockerfile          # base public.ecr.aws/lambda/nodejs:22
│   │   └── src/handler.js
│   └── ping/                   # function: GET /ping
│       ├── Dockerfile
│       └── src/handler.js
├── terraform/
│   ├── environments/
│   │   └── dev-local/          # aponta para o floci (localhost:4566)
│   │       ├── main.tf         # orquestra as functions (ecr + lambda + api-gateway por function)
│   │       ├── providers.tf   # endpoints -> localhost:4566
│   │       ├── variables.tf / outputs.tf / versions.tf
│   └── modules/                # padrao da organizacao
│       ├── lambda/             # IAM role + policy secrets + aws_lambda_function (Image)
│       ├── api-gateway/        # REST API + proxy {proxy+} (AWS_PROXY)
│       ├── ecr/                # repositorio ECR
│       ├── secrets-manager/    # secret + version (config sensivel)
│       ├── aurora-postgres/    # RDS Aurora (disponivel, nao usado na POC)
│       └── dynamodb-poison-messages/  # DLQ DynamoDB (disponivel, nao usado na POC)
├── scripts/
│   ├── build.sh                # builda todas as functions
│   ├── deploy.sh               # build + terraform apply + push (fallback)
│   └── invoke.sh               # invoca as rotas via API Gateway
└── docker-compose.yml          # floci (porta 4566 + docker socket)
```

---

## Como funciona

- **Monorepo**: cada pasta em `functions/` é uma Lambda independente (imagem
  própria no ECR). Adicionar uma function = criar a pasta + declarar os módulos
  no `dev-local/main.tf`.
- **Um API Gateway por function** (proxy `{proxy+}`), padrão da organização.
- **Secrets Manager**: config sensível fora do código (padrão da org).
- **floci**: emula Lambda (Docker real), API Gateway, IAM, ECR, Secrets
  Manager, etc. O deploy usa a imagem local pelo nome — o floci não expõe
  registry de blobs, então o `docker push` é opcional (o script tenta e ignora).

### Como funciona uma Lambda (para quem está começando)

- O `handler.js` de cada function exporta um `handler` que recebe o **evento**
  (request do API Gateway) e retorna uma **resposta HTTP** no formato proxy:
  `{ statusCode, headers, body }`.
- O `Dockerfile` usa a imagem base oficial `public.ecr.aws/lambda/nodejs:22`,
  que já traz o runtime e o entrypoint — o `CMD ["handler.handler"]` aponta
  para o arquivo `handler.js` e a função exportada `handler`.
- O Terraform cria a infra (ECR, Lambda, API Gateway, Secrets) e o `image_uri`
  aponta para a imagem que o `build.sh` gerou localmente.

---

## Adicionar uma nova function

1. Crie `functions/<nome>/` com `Dockerfile` + `src/handler.js` (copie de `ping/`).
2. No `terraform/environments/dev-local/main.tf`, adicione os módulos
   `ecr_<nome>`, `lambda_<nome>` e `api_gateway_<nome>` (copie o bloco do `ping`).
3. No `outputs.tf`, adicione o output `api_gateway_<nome>_invoke_url`.
4. `npm run deploy` e `npm run invoke`.

---

## Configuração

As credenciais e endpoints do floci são **hardcoded no `providers.tf`**
(`test`/`test`, `localhost:4566`) — padrão de ambiente local da organização.
Não há variáveis de ambiente a configurar.

---

## Troubleshooting

| Problema                                                   | Causa                                                | Solução                                                                                    |
| ---------------------------------------------------------- | ---------------------------------------------------- | ------------------------------------------------------------------------------------------ |
| `Failed to start Lambda container`                         | Docker socket não montado                            | O `docker-compose.yml` monta `/var/run/docker.sock` — obrigatório                          |
| Push ECR falha com `400 Bad Request`                       | floci não expõe registry de blobs                    | Normal — o script ignora; a Lambda usa a imagem local pelo nome                            |
| `EntityAlreadyExists` / `ResourceExistsException` no apply | Recursos antigos persistem no floci (state removido) | Limpar o floci: `docker compose down` + `rm -rf data` + `docker compose up -d` + reaplicar |
| `Unsupported path: /timeoutInMillis`                       | floci não suporta update de integration existente    | Já tratado via `ignore_changes` no módulo api-gateway (sem impacto em prod)                |
| Build falha (imagem base AWS)                              | Sem acesso a `public.ecr.aws`                        | `docker pull public.ecr.aws/lambda/nodejs:22` antes                                        |

---

## Notas

- Os dados do floci são **efêmeros** (`data/`): ao recriar o container, o state
  do emulador é perdido — basta reaplicar o terraform.
- O state do Terraform é **local e descartável** em dev (`.gitignore`), padrão
  da organização.
- Em produção, o fluxo real de CI/CD é: build da imagem → push ECR →
  `aws lambda update-function-code`.

---

## Referência

- floci: https://floci.io/floci/ · https://github.com/floci-io/floci
