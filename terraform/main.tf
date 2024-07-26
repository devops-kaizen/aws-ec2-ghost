provider "aws" {
  region = "eu-north-1"
}

resource "aws_key_pair" "deployer_1" {
  key_name   = "ghost_server_key_1"
  public_key = file("../auth/ghost_server_key_1.pub")
}

resource "aws_security_group" "ghost_sg_1" {
  name        = "ghost_sg_1"
  description = "Security group for Ghost server"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 2368
    to_port     = 2368
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "ghost_server" {
  ami           = "ami-07c8c1b18ca66bb07"
  instance_type = "t3.micro"
  key_name      = aws_key_pair.deployer_1.key_name

  associate_public_ip_address = true

  vpc_security_group_ids = [aws_security_group.ghost_sg_1.id]

  tags = {
    Name = "GhostServer"
  }
}

output "ghost_instance_ip" {
  value = aws_instance.ghost_server.public_ip
}
