# Instalação das Ferramentas (formato da POC)

Guia de instalação de todas as ferramentas usadas na POC — Docker, Terraform,
Node.js e floci. Cada seção tem: instalação (macOS/Linux), verificação e
alternativas.

---

## 1. Docker (com Docker Compose)

Necessário para rodar o **floci** (emulador AWS) e **buildar as imagens** das Lambdas.

### macOS (Docker Desktop)
```bash
brew install --cask docker
# ou baixe em: https://www.docker.com/products/docker-desktop/
```

### Linux (engine + compose plugin)
```bash
curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker $USER   # reabra o terminal
```

### Verificar
```bash
docker --version        # Docker version 20+
docker compose version   # Docker Compose v2+
```

---

## 2. Terraform

Necessário para **criar a infraestrutura** (Lambda, API Gateway, S3, SQS, RDS, MSK).

### macOS (Homebrew)
```bash
brew tap hashicorp/tap
brew install hashicorp/tap/terraform
```

### Linux (binário oficial)
```bash
wget https://releases.hashicorp.com/terraform/1.15.8/terraform_1.15.8_linux_amd64.zip
unzip terraform_*.zip
sudo mv terraform /usr/local/bin/
```

### Alternativa: tfenv (gerenciar versões)
```bash
brew install tfenv
tfenv install 1.15.8
tfenv use 1.15.8
```

### Verificar
```bash
terraform version   # Terraform v1.5+ (a POC exige >= 1.5)
```

---

## 3. Node.js 22

Necessário para **buildar as imagens** das functions (runtime da Lambda).

### macOS (Homebrew)
```bash
brew install node@22
```

### Alternativa: nvm (gerenciar versões)
```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
nvm install 22
nvm use 22
```

### Verificar
```bash
node --version   # v22.x
```

---

## 4. floci (emulador AWS local)

O floci emula a AWS na sua máquina (porta `4566`) — **sem custo e sem conta AWS**.
Na POC ele roda via **Docker Compose** (formato do projeto):

```yaml
# docker-compose.yml (já está no projeto)
services:
  floci:
    image: floci/floci:latest
    ports:
      - "4566:4566"
    volumes:
      - ./data:/app/data
      - /var/run/docker.sock:/var/run/docker.sock   # obrigatório p/ Lambda
```

### Subir
```bash
docker compose up -d
```

### Verificar
```bash
curl http://localhost:4566/_localstack/health   # deve retornar JSON com services
```

> O **Docker socket** é obrigatório: o floci sobe containers reais para rodar
> as Lambdas. Sem ele, `Failed to start Lambda container`.

---

## 5. (Opcional) AWS CLI

A POC **não usa** o AWS CLI (o deploy é via Terraform + Docker). Mas é útil para
inspecionar recursos manualmente:

```bash
brew install awscli
aws --version
```

---

## Resumo do que cada ferramenta faz na POC

| Ferramenta | Papel na POC |
|------------|--------------|
| **Docker** | Roda o floci + builda as imagens das functions |
| **Terraform** | Cria a infra (Lambda, API GW, S3, SQS, RDS, MSK) |
| **Node.js 22** | Runtime das functions (imagem base da Lambda) |
| **floci** | Emula a AWS localmente (porta 4566) |

## Fluxo completo após instalar

```bash
# 1. Sobe o emulador AWS local
docker compose up -d

# 2. Deploy (build das functions + terraform init + apply)
npm run deploy

# 3. Invoca as rotas
npm run invoke
```
