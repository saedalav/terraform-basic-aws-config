
variable "region" {
  description= "AWS Region" 
}

variable "vpc_cidr" {
    description = "CIDR for the whole VPC"
}

variable "public_subnet_cidr" {
    description = "CIDR for the Public Subnet"
}

variable "private_subnet_cidr" {
    description = "CIDR for the Private Subnet"
}

variable "bastion_host_ami" {
    description = "AMI for the bastion host"
}


variable "default_tags" {
  type = "map"
  default = {}
}

variable "bastion_key_name" {
	type= "string" 
	default = "bastion_key"
}

variable "private_key_name" {
  type = "string" 
  default = "private_key" 
}
