provider "aws" {
    region = var.REGION
    access_key = var.AWS_ACCESS_KEY
    secret_key = var.AWS_SECRET_KEY
}

resource "aws_vpc" "Aurion-VPC" {
    cidr_block  = "10.0.0.0/16"

    tags = {
        Name = "Aurion-VPC"
    }
}

resource "aws_subnet" "public-1a" {
    vpc_id = aws_vpc.Aurion-VPC.id
    cidr_block = "10.0.1.0/24"
    map_public_ip_on_launch = true
    availability_zone = "${var.REGION}a"

    tags = {
        Name = "Public-1a"
    }
}   

resource "aws_subnet" "private-1a" {
    vpc_id = aws_vpc.Aurion-VPC.id
    cidr_block = "10.0.2.0/24"
    availability_zone = "${var.REGION}a"

    tags = {
        Name = "Private-1a"
    }
}   

resource "aws_security_group" "allow-ssh" {
    name = "allow_ssh"
    description = "Allow SSH traffic"
    vpc_id = aws_vpc.Aurion-VPC.id


    ingress {
      cidr_blocks = [ "${local.my_ip}/32" ]
      description = "Allow port 22 - inbound"
      from_port = 22
      protocol = "tcp"
      to_port = 22
    }


    egress {
      cidr_blocks = [ "0.0.0.0/0" ]
      description = "Allow all - outbound"
      from_port = 0
      protocol = "tcp"
      to_port = 0
    }
}

resource "aws_key_pair" "app_ssh" {
    key_name = "application-ssh"
    public_key = file("app-ssh.pub")

    tags = {
        Name = "application-ssh"
    }
}

# resource "aws_eip" "elastic_ip" {
#     instance = aws_instance.aegon-vm.id
#     vpc = true

#     tags = {
#         Name = "Aurion-EIP"
#     }
# }

# resource "aws_internet_gateway" "gw" {
#     vpc_id = aws_vpc.Aurion-VPC.id

#      tags = {
#         Name = "Aurion-IGW"
#     }
# }

resource "aws_instance" "aegon-vm" {
    ami = lookup(var.AMIS, var.REGION)
    instance_type = "t3.micro"
    subnet_id = aws_subnet.public-1a.id
    vpc_security_group_ids = [aws_security_group.allow-ssh.id]
    associate_public_ip_address = true
    key_name = aws_key_pair.app_ssh.key_name

    provisioner "local-exec" {
        command = "echo ${aws_instance.aegon-vm.public_ip} > ./aegon-address"
    }

    connection {
        type = "ssh"
        user = "ec2-user"
        host = self.public_ip
        private_key = file("app-ssh")
    }

    provisioner "remote-exec" {
        inline = [
          "echo 'LOOOOL'"
        ]
    }

    tags = {
        Name = "Aegon-VM"
    }
}
