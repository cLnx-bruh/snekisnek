variable "access_key" {
    type = string
}

variable "secret_key" {
    type = string
}

variable "region" {
    default = "eu-central-1"
    type = string
}

variable "vpc_cidr_block" {
    default = "10.0.0.0/16"
    type = string
    
}

variable "public_subnet_cidr_blocks" {
    default = ["10.0.0.0/24", "10.0.2.0/24"]
    type = list
}

variable "private_subnet_cidr_blocks" {
    default = ["10.0.1.0/24","10.0.3.0/24"]
    type = list
}

variable "availability_zones" {
    default = ["eu-central-1a", "eu-central-1b"]
    type = list
}

variable "snek-zone" {
    default = "Z02830791NMZ8IZLKJ8YO"
    type = string
}


