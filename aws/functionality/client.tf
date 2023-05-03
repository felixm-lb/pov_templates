data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "client" {
    depends_on = [aws_route.igw]

  count = var.client_count

  ami           = data.aws_ami.ubuntu.id
  instance_type = var.client_instance_type[0]
  key_name = aws_key_pair.generated_key.id
  associate_public_ip_address = false
  availability_zone = var.availability_zone[0]
  subnet_id = data.aws_subnet.private_sn.id
  security_groups = [ data.aws_security_group.targets.id ]

  user_data = "${file("configure_ubuntu_client.sh")}"

  tags = merge(var.tags, {Name = "lb-demo-client-${count.index}"})
}