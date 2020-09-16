variable "ami-id" {
  default = "ami-08c148bb835696b45"
  type    = string
}

variable "instance-type" {
  default = "t2.micro"
  type    = string
}

variable "name" {
  default = "SnakeBE"
  type    = string
}
variable "security-group-ids" {
  type = list(string)
}