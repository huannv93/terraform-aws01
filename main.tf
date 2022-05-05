variable "access_key" {
   type=string
}

variable "secret_key" {
   type=string
}


provider "aws" {
  region     = "us-west-2"
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
}

resource "aws_instance" "hello" {
  ami           = "ami-09dd2e08d601bff67"
  instance_type = "t2.micro"
  tags = {
    Name = "HelloWorld"
  }
}
