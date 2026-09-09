# AWS Lambda — O que é e para que serve

> **Ferramentas necessárias**: Docker, Node.js 22 e floci — veja
> [00 — Instalação das Ferramentas](../00-instalacao-ferramentas.md).

## O que é
Lambda é o serviço de **computação serverless** da AWS: você sobe **código** e a
AWS executa sob demanda, sem gerenciar servidor. Você paga só pelo tempo de
execução.

## Para que serve
- **Rodar código sem servidor**: sem EC2, sem Kubernetes, sem infra para manter.
- **Escala automática**: a AWS sobe/desce instâncias conforme a demanda.
- **Event-driven**: a Lambda é invocada por eventos (HTTP, fila, bucket, etc.).
- **Custo sob demanda**: paga por invocação e tempo, não por máquina ligada.

## Como a Lambda roda nesta POC

Cada function é uma **container image** (Docker) com Node.js 22:

```dockerfile
# functions/health/Dockerfile
FROM public.ecr.aws/lambda/nodejs:22   # imagem oficial com o runtime da AWS
COPY src/handler.js ${LAMBDA_TASK_ROOT}/
CMD ["handler.handler"]                # aponta para o handler exportado
```

> A imagem oficial já inclui o **Runtime Interface Emulator (RIE)** — o
> "motor" que a AWS usa para invocar o seu código.

## Conceitos-chave

| Conceito | O que é |
|----------|---------|
| **Handler** | Função exportada que a AWS chama (`exports.handler`) |
| **Evento** | O que dispara a Lambda (request HTTP, mensagem SQS, etc.) |
| **Runtime** | Ambiente de execução (Node 22, Python, .NET, etc.) |
| **Container image** | Empacotar a Lambda como imagem Docker (padrão desta POC) |
| **Trigger** | Fonte de eventos (API Gateway, SQS, S3, etc.) |
| **Warm start** | Reuso da mesma instância entre invocações (clientes ficam vivos) |

## Estrutura do monorepo

```
functions/
├── health/      # GET /health (exemplo simples)
├── postgres/    # integração com Postgres (RDS)
├── kafka/       # publica evento no Kafka
├── sqs/         # envia/processa mensagens SQS
└── s3/          # upload/download no S3
```

Cada pasta é uma Lambda independente com seu `Dockerfile` + `src/handler.js`.

## Fluxo de uma invocação

```
API Gateway (HTTP) ──> Lambda (handler) ──> resposta { statusCode, body }
SQS (mensagem) ──────> Lambda (handler) ──> processa e loga
```

> A Lambda recebe um **evento** (JSON) e retorna uma **resposta** (JSON).
