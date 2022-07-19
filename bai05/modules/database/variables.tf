variable "project" {
  type = string
}

variable "vpc" {
  type = any
}

variable "sg" {
  type = any
}

# tu them vao :
variable "database_subnets" {
  type    = list(string)
}


#variable "xxx_subnets" {
#  type    = list(string)
#}

