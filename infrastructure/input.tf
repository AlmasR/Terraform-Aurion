variable "AWS_ACCESS_KEY" {}

variable "AWS_SECRET_KEY" {}

variable "REGION" {}

variable "AMIS" {
    type = map
    default = {
        "eu-west-1" : "ami-09e2d756e7d78558d",
        "us-east-1" : "05fa00d4c63e32376"
    }
}

data "http" "my_public_ip" {
    url = "https://ifconfig.co/json"
    request_headers = {
        Accept = "application/json"
    }
}

locals {
  my_ip = jsondecode(data.http.my_public_ip.body).ip
}