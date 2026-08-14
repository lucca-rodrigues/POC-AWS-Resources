# Lambda local com floci

Crie e publique uma **AWS Lambda** localmente usando o **floci** (emulador de AWS
via Docker). O deploy usa **Infraestrutura como Código (IaC)** com o formato
**SAM** — o mesmo fluxo real de produção, mas rodando na sua máquina.

---

## Como funciona

O floci (v1.6.0+) **expande o transform SAM** no CloudFormation. Você define a
Lambda em `src/app/template.yaml` e o script `src/floci.js` publica no floci,
espelhando o que `sam package` + `sam deploy` fazem na AWS real.

```
empacotar código → publicar → invocar → limpar
```

> **Sobre o S3:** o deploy usa o S3 **internamente** para subir o pacote da
> função (ZIP) que o CloudFormation referencia — é o mesmo mecanismo do `sam
> package`. Não é uma funcionalidade extra; é só o transporte do código.

> **SAM** aqui é o **formato** de definição da infra (IaC), não o SAM CLI. O
> floci entende esse formato — **não precisamos do SAM CLI**.

---

## Como usar

```bash
# 1. Sobe o emulador floci (Docker)
docker compose up -d

# 2. Instala dependências (só na primeira vez)
npm install

# 3. Cria e publica a Lambda no floci (mantém no ar)
npm run floci:deploy

# 4. Acessa (invoca) a Lambda já publicada
npm run floci:invoke

# 5. Limpa o ambiente quando terminar
npm run floci:delete
```

Saída esperada do deploy:

```
[1] Bucket S3 criado: sam-study-bucket
[2] Código empacotado e enviado: s3://sam-study-bucket/function.zip
[3] Stack criada: sam-study (aguardando CREATE_COMPLETE...)
[4] Stack pronta (CREATE_COMPLETE)
-> sam-study-HelloFunction-... respondeu: { statusCode: 200, body: '{"message":"Hello Lucas!",...}' }

✅ Lambda publicada e no ar! Nome: sam-study-HelloFunction-...
```

| Script | O que faz |
|--------|-----------|
| `npm run floci:deploy` | Cria e publica a Lambda (mantém no ar) |
| `npm run floci:invoke` | Acessa (invoca) a Lambda já publicada |
| `npm run floci:delete` | Limpa (deleta a stack e o S3) |

O passo `-> ... respondeu` mostra a **invocação da Lambda** — é a função criada sendo usada.

---

## Estrutura

```
src/
├── app/
│   ├── template.yaml        # IaC — define a Lambda (runtime, env, handler)
│   └── src/handler.js       # Código real da Lambda (CommonJS)
├── floci.js                 # Publica a Lambda no floci
└── resources/
    └── lambda-zip.js        # Empacota o código em ZIP
```

- **`src/app/src/handler.js`** — onde você escreve o código da função (edite aqui).
- **`src/app/template.yaml`** — onde você declara a infra da Lambda (edite aqui).
- **`src/floci.js`** — CLI: cria e publica, acessa (invoca) e limpa a Lambda.
  - `deploy` → cria e publica (mantém no ar)
  - `invoke` → acessa a função já publicada
  - `delete` → limpa o ambiente

---

## Configuração

Variáveis de ambiente (opcionais, com defaults):

| Variável | Default |
|----------|---------|
| `FLOCI_ENDPOINT` | `http://localhost:4566` |
| `AWS_REGION` | `us-east-1` |
| `AWS_ACCESS_KEY_ID` | `test` |
| `AWS_SECRET_ACCESS_KEY` | `test` |

---

## Notas

- O `docker-compose.yml` monta o Docker socket (`/var/run/docker.sock`) no floci.
  Isso é **obrigatório** para a Lambda funcionar (o floci sobe containers reais).
- Os dados são **efêmeros** — ao recriar o container, são perdidos.

---

## Referência

- Doc oficial: https://floci.io/floci/
- Repo: https://github.com/floci-io/floci
- Guia de Lambda: https://medium.com/@lingeshcbz/the-ultimate-guide-to-aws-lambda-zero-to-hero-3917fb5d6ea8
