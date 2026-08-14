# Floci — Testes locais de AWS (S3, Lambda, EC2)

Emulador local de serviços AWS (69 serviços) rodando via Docker. Um servidor Node (`src/server.js`) serve de **ponte** para testar S3, Lambda e EC2 via HTTP.

---

## O que faz

| Serviço | Rotas |
|---------|-------|
| **S3** | listar buckets, criar bucket, upload de objeto, download de objeto |
| **Lambda** | criar função, invocar função |
| **EC2** | descrever instâncias |

---

## Como subir e testar

```bash
# 1. Sobe o emulador floci (Docker)
docker compose up -d

# 2. Instala dependências (só na primeira vez)
npm install

# 3. Sobe o servidor ponte
npm run start
```

O servidor fica em `http://localhost:3000`. O floci fica em `http://localhost:4566`.

> **Importante:** o `docker-compose.yml` monta o Docker socket (`/var/run/docker.sock`) no container do floci. Isso é **obrigatório** para a Lambda funcionar, pois o floci sobe containers Docker reais para executar as funções. Sem o socket, a invocação falha com `Failed to start Lambda container`.

---

## Testar S3

```bash
# Listar buckets
curl http://localhost:3000/s3/buckets

# Criar bucket
curl -X POST http://localhost:3000/s3/bucket \
  -H "Content-Type: application/json" \
  -d '{"bucket":"my-bucket"}'

# Upload de objeto
curl -X POST http://localhost:3000/s3/upload \
  -H "Content-Type: application/json" \
  -d '{"bucket":"my-bucket","key":"hello.txt","body":"Hello Floci!"}'

# Download de objeto
curl http://localhost:3000/s3/object/my-bucket/hello.txt
```

---

## Testar Lambda

### 1. Criar a função

A função precisa ser enviada como **base64 de um ZIP** contendo o código. Exemplo com um handler simples:

```bash
# Cria o código da função
mkdir -p /tmp/lambda && cd /tmp/lambda
cat > index.js <<'EOF'
exports.handler = async (event) => {
  return { message: `Hello ${event.name || "world"}!` };
};
EOF

# Empacota em ZIP e converte para base64
zip -r function.zip index.js
ZIP_B64=$(base64 -i function.zip)
```

### 2. Enviar para o floci

```bash
curl -X POST http://localhost:3000/lambda/function \
  -H "Content-Type: application/json" \
  -d "{\"name\":\"my-function\",\"handler\":\"index.handler\",\"role\":\"arn:aws:iam::000000000000:role/lambda-role\",\"code\":\"$ZIP_B64\"}"
```

### 3. Invocar a função

```bash
curl -X POST http://localhost:3000/lambda/invoke \
  -H "Content-Type: application/json" \
  -d '{"name":"my-function","payload":{"name":"Lucas"}}'
```

Resposta esperada:

```json
{
  "statusCode": 200,
  "response": { "message": "Hello Lucas!" }
}
```

---

## Testar EC2

```bash
# Descrever instâncias (vazio no início)
curl http://localhost:3000/ec2/instances
```

---

## Validar que está funcionando

1. `docker compose ps` → o container `floci` deve estar `Up`.
2. `curl http://localhost:3000/s3/buckets` → deve retornar `{"buckets":[]}` (ou os buckets criados).
3. Criar um bucket e listar de novo → o bucket deve aparecer.
4. Criar e invocar a Lambda → deve retornar a mensagem do handler.

> **Nota:** os dados (buckets/objetos) são **efêmeros** — ao recriar o container (`docker compose up -d --force-recreate`), eles são perdidos. O floci também cria um bucket interno `awslambda-us-east-1-tasks` para a Lambda.

---

## Configuração

Variáveis de ambiente (opcionais, com defaults):

| Variável | Default |
|----------|---------|
| `FLOCI_ENDPOINT` | `http://localhost:4566` |
| `AWS_REGION` | `us-east-1` |
| `AWS_ACCESS_KEY_ID` | `test` |
| `AWS_SECRET_ACCESS_KEY` | `test` |
| `PORT` | `3000` |

---

## Referência

- Doc oficial: https://floci.io/floci/
- Repo: https://github.com/floci-io/floci
