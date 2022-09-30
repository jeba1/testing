provider "aws" {
    region = "us-east-1"
}

data "aws_availability_zones" "avai" {}
data "aws_vpc" "main" {}
data "aws_ami" "ubuntu" {
  
  most_recent      = true
  owners           = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}


resource "aws_instance" "devsec" {
    ami = data.aws_ami.ubuntu.id
    instance_type = "t3.micro"
    user_data = file("data.sh")
    
    

}


resource "aws_security_group" "allow_tls1" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = data.aws_vpc.main.id

  dynamic "ingress" {
        for_each = ["22", "8080", "80"]   
        content{
           
            from_port        = ingress.value
            to_port          = ingress.value
            protocol         = "tcp"
            cidr_blocks      = [data.aws_vpc.main.cidr_block]
        }
   }

    egress {
        from_port        = 0
        to_port          = 0
        protocol         = "-1"
        cidr_blocks      = ["0.0.0.0/0"]
        ipv6_cidr_blocks = ["::/0"]
    }

    tags = {
        Name = "allow_tls"
    }
}
output "vpid" {
    value = data.aws_vpc.main.id
}
output "public" {
    value = aws_instance.devsec.public_ip
}
