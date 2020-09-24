#Output for the most important variables

#Public IP address for the bastion host, which is accessable from the public internet
output "bastion-host-public-ip" {
  value = aws_instance.bastion-host.public_ip
}

#Private IP address of the astian host
output "bastion-host-private-ip" {
  value = aws_instance.bastion-host.private_ip
}

#Private IP address for the private host
output "private-host-ip" {
  value = aws_instance.private-host.private_ip
}

###########################
#!!! Sensitive data!!!
###########################

#Priavte key for the bastion host
output "private-key-bastion-host" {
  sensitive = true
  value = tls_private_key.generated-key-bastion-host.private_key_pem
}

#Private key for the private host
output "private-key-private-host" {
  sensitive = true
  #value = tls_private_key.generated-key-private-host.public_key_openssh
  value = tls_private_key.generated-key-private-host.private_key_pem
}