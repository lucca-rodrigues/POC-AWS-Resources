resource "aws_rds_cluster" "corebanking" {
  cluster_identifier = var.cluster_identifier
  engine             = "aurora-postgresql"
  engine_version     = var.engine_version
  database_name      = var.database_name
  master_username    = var.master_username

  # Ou a senha e gerida pelo Secrets Manager (com rotacao), ou vem por variavel. Nunca as duas:
  # a API do RDS rejeita master_password quando manage_master_user_password esta ligado.
  manage_master_user_password = var.manage_master_user_password ? true : null
  master_password             = var.manage_master_user_password ? null : var.master_password

  storage_encrypted      = var.storage_encrypted
  kms_key_id             = var.kms_key_id
  db_subnet_group_name   = var.db_subnet_group_name
  vpc_security_group_ids = var.vpc_security_group_ids

  backup_retention_period = var.backup_retention_period
  preferred_backup_window = var.preferred_backup_window
  deletion_protection     = var.deletion_protection

  skip_final_snapshot       = var.skip_final_snapshot
  final_snapshot_identifier = var.skip_final_snapshot ? null : "${var.cluster_identifier}-final"
  apply_immediately         = var.apply_immediately
}

resource "aws_rds_cluster_instance" "corebanking" {
  count                = var.instance_count
  identifier           = "${var.cluster_identifier}-${count.index + 1}"
  cluster_identifier   = aws_rds_cluster.corebanking.id
  instance_class       = var.instance_class
  engine               = aws_rds_cluster.corebanking.engine
  engine_version       = aws_rds_cluster.corebanking.engine_version
  db_subnet_group_name = var.db_subnet_group_name
  apply_immediately    = var.apply_immediately
}
