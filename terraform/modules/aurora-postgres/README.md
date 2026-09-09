# Modulo `aurora-postgres`

Provisiona um cluster **Aurora PostgreSQL** (`aws_rds_cluster` + `aws_rds_cluster_instance`).

Funciona tanto contra a AWS real quanto contra o **ministack** (emulador local). No
ministack, a criacao do cluster sobe um container `postgres` real, exposto em uma porta
a partir de `15432`.

## Uso

```hcl
module "aurora" {
  source = "./modules/aurora-postgres"

  cluster_identifier = "core-bancario-cliente"
  database_name      = "core_bancario_cliente"
  master_username    = "postgres"
  master_password    = var.master_password
}
```

## Inputs

| Nome | Tipo | Default | Descricao |
|------|------|---------|-----------|
| `cluster_identifier` | string | — | Identificador do cluster. |
| `database_name` | string | — | Nome do banco inicial. |
| `master_username` | string | — | Usuario master. |
| `master_password` | string (sensivel) | — | Senha do usuario master. |
| `engine_version` | string | `15.4` | Versao do Aurora PostgreSQL. |
| `instance_class` | string | `db.t3.medium` | Classe das instancias (ignorada pelo ministack). |
| `instance_count` | number | `1` | Quantidade de instancias (1 writer; >1 adiciona readers). |
| `apply_immediately` | bool | `true` | Aplica alteracoes imediatamente. |
| `skip_final_snapshot` | bool | `true` | Nao cria snapshot final ao destruir. |

## Outputs

| Nome | Descricao |
|------|-----------|
| `cluster_id` | Identificador do cluster. |
| `cluster_endpoint` | Endpoint de escrita (writer). |
| `reader_endpoint` | Endpoint de leitura (reader). |
| `port` | Porta do cluster. |
| `database_name` | Nome do banco inicial. |
