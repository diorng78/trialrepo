resource "aws_instance" "web_server" {
  ami           = "ami-0f34c5ae932e6f0e4" # Amazon Linux 2 LTS
  instance_type = "t2.micro"
  key_name      = aws_key_pair.my_keypair.key_name # for SSH connection with a new key pair created below
  vpc_security_group_ids = [aws_security_group.allow_http_https_ssh_traffic.id]
  associate_public_ip_address = true

  tags = {
    Name = "Diorng-EC2"
  }
}

resource "aws_security_group" "allow_http_https_ssh_traffic" {
  name        = "kingkong-vpc"
  description = "Allow inbound traffic for https, http and ssh"

  ingress {
    description      = "SSH inbound"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_tls"
  }
}

# Below resources will create a key pair to your local computer on the same path as your terraform folder
resource "tls_private_key" "private_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "my_keypair" {
  key_name   = "kkong7887-us-east-1-key"       # Create a key called "my-us-east-1-key" in AWS
  public_key = tls_private_key.private_key.public_key_openssh

 provisioner "local-exec" {
  command = "echo '${tls_private_key.private_key.private_key_pem}' > ./kkong7887-us-east-1-key.pem"
  interpreter = ["PowerShell", "-Command"]
}
}

terraform {
  backend "s3" {
    bucket = "sctp-ce3-tfstate-bucket"
    key = "diorng.tfstate"
    region = "us-east-1"
  }
}
