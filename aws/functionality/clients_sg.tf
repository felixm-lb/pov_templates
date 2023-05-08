resource "aws_security_group" "clients" {
  name        = "allow_client"
  description = "Allow client inbound traffic"
  vpc_id      = data.aws_vpc.lb_vpc.id

  ingress {
    description      = "Traffic from VPC"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = [data.aws_vpc.lb_vpc.cidr_block]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = var.tags
}