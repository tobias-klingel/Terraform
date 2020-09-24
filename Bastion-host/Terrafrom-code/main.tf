##################################################################
#Network
#############

#VPC
resource "aws_vpc" "myVPC" {
  cidr_block = "10.0.0.0/16"
}

#Public facing setup
resource "aws_internet_gateway" "default" {
  vpc_id = aws_vpc.myVPC.id
}

#Route for internet gateway
resource "aws_route" "internet_access" {
  route_table_id         = aws_vpc.myVPC.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.default.id
}

#Public subnet
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.myVPC.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = var.aws_availability_zone

  tags = {
    Name = "public-subnet"
  }
}

#############################
#Private subnet
resource "aws_subnet" "private" {
  vpc_id                  = aws_vpc.myVPC.id
  cidr_block              = "10.0.254.0/24"
  map_public_ip_on_launch = "false"
  availability_zone       = var.aws_availability_zone

  tags = {
    Name = "private-subnet"
  }
}

##################################################################
#Security Groups
################

#Public facing
resource "aws_security_group" "allow_ssh" {
  name        = "Public facing security group"
  description = "Allow ssh inbound traffic"
  vpc_id      = aws_vpc.myVPC.id

  ingress {
    description = "ssh to VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]   # SSH access from anywhere
  }
   # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name = "allow_ssh"
  }
}

#Allow SSH from bastion host
resource "aws_security_group" "allow_ssh_from_bastion_host" {
  name        = "SSH in private subnet"
  description = "Allow only to access private host from private subnet"
  vpc_id      = aws_vpc.myVPC.id

  ingress {
    description = "ssh in VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.0.0.0/16"]
  }
  
  tags = {
    Name = "allow_ssh_from_private_VPC"
  }
}


##################################################################
#EC2 instances
###############

# This retrieves the latest AMI ID for Ubuntu 16.04.
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

#Creates instance for bastion host
resource "aws_instance" "bastion-host" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  availability_zone      = var.aws_availability_zone
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]
  subnet_id              = aws_subnet.public.id
  key_name               = var.bastion-host-key_name

  tags = {
    Name = "bastion-host"
  }
}

#Creates instance for private host
resource "aws_instance" "private-host" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  availability_zone      = var.aws_availability_zone
  vpc_security_group_ids = [aws_security_group.allow_ssh_from_bastion_host.id]
  subnet_id              = aws_subnet.private.id
  key_name               = var.private-host-key_name

  tags = {
    Name = "private-host"
  }
}


#############################
#Creating of keys
##################

#Keys for bastion host
resource "tls_private_key" "generated-key-bastion-host" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key-bastion-host" {
  key_name   = var.bastion-host-key_name
  public_key = tls_private_key.generated-key-bastion-host.public_key_openssh
}


#Keys for private host
resource "tls_private_key" "generated-key-private-host" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key-private-host" {
  key_name   = var.private-host-key_name
  public_key = tls_private_key.generated-key-private-host.public_key_openssh
}

#Alternative of using a pre-generated key
/*
resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQD3F6tyPEFEzV0LX3X8BsXdMsQz1x2cEikKDEY0aIj41qgxMCP/iteneqXSIFZBp5vizPvaoIR3Um9xK7PGoW8giupGn+EPuxIA4cDM4vzOqOkiMPhz5XK0whEjkVzTo4+S0puvDZuwIsdiW9mxhJc7tgBNL0cYlWSYVkz4G/fslNfRPW5mYAM49f4fhtxPb5ok4Q2Lg9dPKVHO/Bgeu5woMc7RY0p1ej6D4CKFE6lymSDJpW0YHX/wqE9+cfEauh7xZcG0q9t2ta6F6fmX0agvpFyZo8aFbXeUBr7osSCJNgvavWbM/06niWrOvYX2xwWdhXmXSrbX8ZbabVohBK41 email@example.com"
}
*/
/*
resource "aws_key_pair" "mykeypair" {
  key_name   = "mykeypair"
  public_key = file(var.key_path)
}
*/

##################################################################
