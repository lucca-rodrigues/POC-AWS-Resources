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

## 📚 Conceitos (para quem está começando)

Docs didáticas e objetivas — base inicial para quem nunca atuou com Terraform/Lambda:

### Instalação
- [00 — Instalação das Ferramentas (Docker, Terraform, Node, floci)](conceitos/00-instalacao-ferramentas.md)

### Terraform
- [01 — O que é e para que serve](conceitos/terraform/01-o-que-e-terraform.md)
- [02 — Como usar (init, plan, apply, destroy)](conceitos/terraform/02-como-usar.md)
- [03 — Módulos, Variáveis e Outputs](conceitos/terraform/03-modulos-e-variaveis.md)
- [04 — Setup na máquina](conceitos/terraform/04-setup.md)
- [05 — Variáveis de Ambiente (POC vs Prod)](conceitos/terraform/05-variaveis-de-ambiente.md)
- [06 — Step Functions (orquestração de fluxos)](conceitos/terraform/06-step-functions.md)
- [07 — DynamoDB (banco NoSQL)](conceitos/terraform/07-dynamodb.md)
- [08 — VPC Privada (segurança)](conceitos/terraform/08-vpc-privada.md)

### AWS Lambda
- [01 — O que é e para que serve](conceitos/lambda/01-o-que-e-lambda.md)
- [02 — Handler, Eventos e Resposta](conceitos/lambda/02-handler-e-eventos.md)
- [03 — Triggers e Integrações](conceitos/lambda/03-triggers-e-servicos.md)
- [04 — Monitoramento e Debug](conceitos/lambda/04-monitoramento-e-debug.md)
- [05 — Variáveis de Ambiente e Configuração](conceitos/lambda/05-variaveis-de-ambiente.md)
- [06 — SDKs e Libs NPM Internas](conceitos/lambda/06-sdks-e-libs-internas.md)

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
```

---

## Estrutura

```
pocs/aws/
├── functions/                  # MONOREPO de functions Lambda
│   ├── health/                 # function: GET /health
│   ├── exemplo-http/           # function HTTP de referência (gerada por npm run gen)
│   ├── postgres/               # function: integracao com Postgres (RDS)
│   ├── kafka/                  # function: publica evento no Kafka (MSK)
│   ├── sqs/                    # function: envia/processa mensagens SQS
│   ├── s3/                     # function: upload/download no S3
│   └── crud-node/              # CRUD TypeORM (create/read/update/delete)
├── terraform/
│   ├── environments/
│   │   └── dev-local/          # aponta para o floci (localhost:4566)
│   │       ├── main.tf         # orquestra as functions + RDS + SQS + S3 + MSK
│   │       ├── providers.tf   # endpoints -> localhost:4566
│   │       ├── variables.tf / outputs.tf / versions.tf
│   └── modules/                # padrao da organizacao
│       ├── lambda/             # IAM role + policy secrets + aws_lambda_function (Image)
│       ├── api-gateway/        # REST API + proxy {proxy+} (AWS_PROXY)
│       ├── ecr/                # repositorio ECR
│       ├── secrets-manager/    # secret + version (config sensivel)
│       ├── aurora-postgres/    # RDS Aurora
│       ├── dynamodb-poison-messages/  # DLQ DynamoDB
│       ├── sqs/                # fila + DLQ
│       └── s3/                 # bucket
├── conceitos/                  # DOCS DIDATICAS (base para iniciantes)
│   ├── terraform/              # o que é, como usar, módulos, setup
│   └── lambda/                 # o que é, handler, triggers, monitoramento
├── infra/
│   └── templates/              # templates hbs do gerador (npm run gen)
├── plopfile.js                 # gerador de functions (npm run gen)
├── .vscode/                    # extensões e formatação recomendadas
├── scripts/
│   ├── build.sh                # builda todas as functions
│   ├── deploy.sh               # build + terraform apply + push (fallback)
│   ├── invoke.sh               # health
│   ├── invoke-functions.sh     # testa postgres/kafka/sqs/s3 via API GW
│   ├── invoke-integracao.sh    # envia mensagem SQS (trigger)
│   └── logs.sh                 # logs de uma function (CloudWatch)
├── references/                 # repos de estudo (nao fazem parte da POC)
└── docker-compose.yml          # floci (porta 4566 + docker socket)
```

---

## Como funciona

- **Monorepo**: cada pasta em `functions/` é uma Lambda independente (imagem
  própria no ECR). Adicionar uma function = criar a pasta + declarar os módulos
  no `dev-local/main.tf`.
- **Uma function por cenário**: `postgres` (RDS), `kafka` (MSK), `sqs` (fila),
  `s3` (bucket) — cada uma demonstra uma integração real.
- **Um API Gateway por function** (proxy `{proxy+}`), padrão da organização.
- **Secrets Manager**: config sensível fora do código (padrão da org).
- **floci**: emula Lambda (Docker real), API Gateway, IAM, ECR, Secrets
  Manager, S3, SQS, RDS, MSK, etc. O deploy usa a imagem local pelo nome — o
  floci não expõe registry de blobs, então o `docker push` é opcional (o
  script tenta e ignora).

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

### Com o gerador (recomendado)

```bash
npm run gen
```

O gerador pergunta o nome, o tipo (`http` / `integracao` / `crud`) e a descrição,
e cria a estrutura completa em `functions/<nome>/` (Dockerfile, package.json,
handler, README) e **insere automaticamente** o bloco terraform no `main.tf`
e o output no `outputs.tf`.

> Depois de gerar: rode `npm run deploy` para publicar a function no floci.

### Manual

1. Crie `functions/<nome>/` com `Dockerfile` + `package.json` + `src/handler.js` (copie de `health/`).
2. No `terraform/environments/dev-local/main.tf`, adicione os módulos
   `ecr_<nome>`, `lambda_<nome>` e `api_gateway_<nome>` (copie o bloco do `health`).
3. No `outputs.tf`, adicione o output `api_gateway_<nome>_invoke_url`.
4. `npm run deploy` e `bash scripts/invoke-functions.sh`.

## Testar as functions de integração

```bash
# testa postgres/kafka/sqs/s3 via API Gateway
bash scripts/invoke-functions.sh

# envia mensagem SQS (dispara o trigger da function sqs)
bash scripts/invoke-integracao.sh

# ver logs de uma function (CloudWatch do floci)
bash scripts/logs.sh futurosign-kafka
```

> **Docs didáticas**: veja `conceitos/terraform/` e `conceitos/lambda/` para
> entender Terraform e Lambda do zero (base para quem nunca usou).

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
