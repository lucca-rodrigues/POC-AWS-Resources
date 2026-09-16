# AWS Step Functions — Orquestração de Fluxos

## O que é
Step Functions é o **orquestrador de workflows** da AWS. Você define uma
**máquina de estados** (ASL) que executa passos em sequência — cada passo pode
ser uma Lambda, uma chamada de API, um wait, etc. Se um passo falha, você sabe
**exatamente onde parou**.

## Para que serve
- **Orquestrar múltiplas Lambdas** em um fluxo (ex.: jornada de assinatura)
- **Saber onde falhou**: registro de cada step + retry automático
- **Visibilidade**: histórico de execução com cada estado
- **Substituir filas/tratamento manual** de fluxos complexos

## A máquina de estados (ASL)

```json
{
  "StartAt": "GerarInvitationToken",
  "States": {
    "GerarInvitationToken": {
      "Type": "Task",
      "Resource": "arn:aws:lambda:...:gerar-token",
      "Next": "CriarJornada"
    },
    "CriarJornada": {
      "Type": "Task",
      "Resource": "arn:aws:lambda:...:criar-jornada",
      "End": true
    }
  }
}
```

| Tipo de estado | Função |
|----------------|--------|
| **Task** | Executa uma Lambda/integração |
| **Choice** | Condicional (if/switch) |
| **Wait** | Espera um tempo |
| **Parallel** | Executa em paralelo |
| **Fail/Succeed** | Termina com erro/sucesso |

## Como a POC usa (jornada FuturoSign)

```
GerarInvitationToken → CriarJornada → CriarEnvelopeClick → EnviarLinkZenvia → AtualizarStatus
```

Cada estado é uma **Lambda** que regista o step no DynamoDB:

```hcl
# terraform/modules/step-functions/main.tf
resource "aws_sfn_state_machine" "this" {
  name       = var.state_machine_name
  role_arn   = aws_iam_role.execution.arn
  definition = var.definition   # ASL JSON
}
```

## Invocar (executar a máquina)

```bash
aws stepfunctions start-execution \
  --state-machine-arn <arn> \
  --input '{"jornada_id":"123"}'
```

## Retry automático (se um step falhar)

```json
"CriarEnvelopeClick": {
  "Type": "Task",
  "Resource": "arn:aws:lambda:...",
  "Retry": [{ "ErrorEquals": ["States.TaskFailed"], "MaxAttempts": 3 }]
}
```

> **Padrão na POC**: cada step regista `{ jornada_id, step, status }` no DynamoDB
> — se falhar, o registro mostra `status=erro` no step exato (premissa da spec).
