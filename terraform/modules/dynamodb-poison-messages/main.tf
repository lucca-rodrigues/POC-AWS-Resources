# Tabela DynamoDB para inspecao operacional de poison messages (CB-174).
#
# Complementa a DLT por dominio (CB-173): toda mensagem que o consumer nao
# consegue processar (schema invalido, erro de parsing, correlacao ausente)
# e enviada a DLT do MSK E registrada aqui, com o motivo da falha, para que
# o time de operacao consiga inspecionar/reprocessar manualmente sem precisar
# ler offset de Kafka.
#
# Chave: dominio (PK) + message_id (SK) — mesmo particionamento por dominio
# da DLT (desembolso, cliente, ...), reaproveitando o message_id que teria
# ido para evento_provider.message_id se a mensagem tivesse sido processada.
#
# GSI por status_inspecao + recebido_em: permite listar todo item PENDENTE
# de um dominio sem varrer a tabela inteira.
resource "aws_dynamodb_table" "this" {
  name         = var.table_name
  billing_mode = var.billing_mode
  hash_key     = "dominio"
  range_key    = "message_id"

  attribute {
    name = "dominio"
    type = "S"
  }

  attribute {
    name = "message_id"
    type = "S"
  }

  attribute {
    name = "status_inspecao"
    type = "S"
  }

  attribute {
    name = "recebido_em"
    type = "S"
  }

  global_secondary_index {
    name            = "gsi_status_inspecao"
    hash_key        = "status_inspecao"
    range_key       = "recebido_em"
    projection_type = "ALL"
  }

  dynamic "ttl" {
    for_each = var.ttl_habilitado ? [1] : []
    content {
      attribute_name = "ttl"
      enabled        = true
    }
  }

  point_in_time_recovery {
    enabled = var.point_in_time_recovery_habilitado
  }

  tags = merge(
    {
      Projeto = "core-bancario-desembolso"
      Card    = "CB-174"
    },
    var.tags
  )
}
