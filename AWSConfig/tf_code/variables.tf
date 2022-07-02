variable "region" {
}


#Defines a periodic trigger time for the aws config rules
variable "low_frequency_awsconfig_rules" {
  default = "TwentyFour_Hours"
}

#Defines a periodic trigger time for the aws config rules
variable "high_frequency_awsconfig_rules" {
  default = "One_Hour"
}


variable "bucket_prefix" {
  default = "config"
}

variable "bucket_key_prefix" {
  default = "config"
}


