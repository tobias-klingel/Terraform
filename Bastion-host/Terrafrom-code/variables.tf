
#Add your AWS account ID
variable "aws-account-id"{
    default = "XXXXXXXXXXXX" #<----- Need to be cahnges
}

#Can be changed optional
variable "aws-region"{
    default = "ap-southeast-1"
}

variable "aws_availability_zone" {
  default = "ap-southeast-1a"
}


#Used variables in the code
variable "bastion-host-key_name" {
  default="bastion-host-key"
}

variable "private-host-key_name" {
  default="private-host-key"
}