# Tabela DynamoDB para registro de steps da jornada (FuturoSign v2).
# O Step Functions registra cada step — se der erro, sabemos onde parou.

resource "aws_dynamodb_table" "this" {
  name         = var.table_name
  billing_mode = var.billing_mode
  hash_key     = var.hash_key
  range_key    = var.range_key

  attribute {
    name = var.hash_key
    type = var.hash_key_type
  }

  attribute {
    name = var.range_key
    type = var.range_key_type
  }
}
