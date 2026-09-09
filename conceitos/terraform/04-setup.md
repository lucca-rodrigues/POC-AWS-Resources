# Terraform — Setup na máquina

> **Instalação das ferramentas**: veja
> [00 — Instalação das Ferramentas](../00-instalacao-ferramentas.md) — Docker,
> Terraform, Node.js e floci (macOS/Linux, com verificação).

## Pré-requisitos

| Ferramenta | Versão | Instalação |
|------------|--------|------------|
| Terraform | 1.5+ | `brew install hashicorp/tap/terraform` |
| Docker | 20+ | `brew install --cask docker` |
| Node.js | 22 | `brew install node@22` |

> Detalhes e alternativas (tfenv, nvm, Linux): [00 — Instalação](../00-instalacao-ferramentas.md)

## Passo a passo

```bash
# 1. Sobe o emulador AWS local (floci)
docker compose up -d

# 2. Deploy (build das functions + terraform init + apply)
npm run deploy

# 3. Invoca as rotas
npm run invoke
```

## O que o deploy faz

1. **Build** das imagens das functions (Docker)
2. **Terraform init** — baixa o provider `aws`
3. **Terraform apply** — cria ECR, Lambdas, API Gateway, Secrets, SQS, S3, RDS
4. **Push** das imagens para o ECR local (opcional — o floci usa a imagem local)

## Emulador local (floci)

O **floci** emula a AWS na sua máquina (porta `4566`). Ele permite testar
Lambda, API Gateway, S3, SQS, RDS, etc. **sem custo e sem conta AWS**.

```yaml
# docker-compose.yml
services:
  floci:
    image: floci/floci:latest
    ports:
      - "4566:4566"
    volumes:
      - ./data:/app/data
      - /var/run/docker.sock:/var/run/docker.sock   # obrigatório p/ Lambda
```

> O **Docker socket** é obrigatório: o floci sobe containers reais para rodar
> as Lambdas.

## Verificando se está tudo certo

```bash
# floci rodando?
curl http://localhost:4566/_localstack/health

# infra criada?
cd terraform/environments/dev-local && terraform output

# logs de uma function?
bash scripts/logs.sh futurosign-health
```

## Troubleshooting rápido

| Problema | Solução |
|----------|---------|
| `Failed to start Lambda container` | Docker socket não montado no docker-compose |
| `InvalidAccessKeyId` no S3/SQS | Falta `endpoints` no providers.tf (apontar para `localhost:4566`) |
| Recursos antigos persistem | `docker compose down` + `rm -rf data` + `docker compose up -d` |
| RDS não acessível | O deploy.sh descobre o container RDS e reaplica com override |
