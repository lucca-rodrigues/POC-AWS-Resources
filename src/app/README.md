# App — Infra como Código (IaC) com SAM

Este diretório define a Lambda usando o formato **SAM** (Serverless Application
Model) — o padrão oficial da AWS para **Infraestrutura como Código (IaC)**.

## Por que SAM?

Na vida real, ninguém cria Lambda chamando o SDK diretamente com ZIP base64.
Devs **declaram a infra** em `template.yaml` e a ferramenta de deploy cuida de
empacotar, testar e publicar.

Aqui, o **floci** é o ambiente que simula a AWS localmente e **expande o
transform SAM** no CloudFormation — então não precisamos do SAM CLI.

## Estrutura

```
src/app/
├── template.yaml        # Infra como código (IaC) — declara a função
└── src/handler.js       # Código real da Lambda (CommonJS)
```

## Publicar no floci

```bash
# Publica a Lambda no floci (empacota -> S3 -> CloudFormation -> invoca -> limpa)
npm run floci:deploy
```

O script `src/sam-floci.js` espelha o que `sam package` + `sam deploy` fazem
na AWS real, mas apontando para o floci (`http://localhost:4566`).

## O que o `template.yaml` declara

| Recurso | Descrição |
|---------|-----------|
| `Globals.Function` | Padrões de todas as funções (runtime, memória, timeout, env vars) |
| `HelloFunction` | A função Lambda (código em `src/`, handler `handler.handler`) |
| `FunctionUrlConfig` | URL HTTPS pública que chama a função diretamente |
| `Outputs` | Endpoint público exibido após o deploy |

## Diferença para o fluxo manual (SDK)

| | Fluxo manual (SDK) | `src/app/` (SAM) |
|---|---|---|
| Nível | Baixo (SDK manual) | Alto (IaC) |
| Deploy | ZIP base64 via SDK | CloudFormation via floci |
| Infra | Manual (role, env) | Declarada em `template.yaml` |
| Uso real | Entender o mecanismo | Fluxo de produção |
