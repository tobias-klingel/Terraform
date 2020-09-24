##################################################################
#AWS secret manager
####################

resource "aws_secretsmanager_secret" "private-key" {
  description = "Storage of the private SSH keys for the bastion hosst and the private"
  name        = "private-key-bastion-host"
}

resource "aws_secretsmanager_secret_version" "private-key-bastion-host" {
  secret_id     = aws_secretsmanager_secret.private-key.id
  secret_string = jsonencode(tls_private_key.generated-key-bastion-host.private_key_pem)
}

resource "aws_secretsmanager_secret_version" "public-key-bastion-host" {
  secret_id     = aws_secretsmanager_secret.private-key.id
  secret_string = jsonencode(tls_private_key.generated-key-bastion-host.public_key_openssh)
}

resource "aws_secretsmanager_secret_version" "private-key-private-host" {
  secret_id     = aws_secretsmanager_secret.private-key.id
  secret_string = jsonencode(tls_private_key.generated-key-private-host.private_key_pem)
}

resource "aws_secretsmanager_secret_version" "public-key-private-host" {
  secret_id     = aws_secretsmanager_secret.private-key.id
  secret_string = jsonencode(tls_private_key.generated-key-private-host.public_key_openssh)
}

