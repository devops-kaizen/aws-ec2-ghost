provider "aws" {
  region = "eu-north-1"
}

resource "aws_key_pair" "deployer" {
  key_name   = "ghost_server_key"
  public_key = file("../auth/ghost_server_key.pub")
}

resource "aws_security_group" "ghost_sg" {
  name        = "ghost_sg"
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

resource "aws_instance" "app_server" {
  ami           = "ami-07c8c1b18ca66bb07"
  instance_type = "t3.micro"
  key_name      = aws_key_pair.deployer.key_name

  associate_public_ip_address = true

  vpc_security_group_ids = [aws_security_group.ghost_sg.id]

  tags = {
    Name = "GhostServer"
  }
}

output "instance_ip" {
  value = aws_instance.app_server.public_ip
}
