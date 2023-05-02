resource "aws_egress_only_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.lb_vpc.id

  tags = var.tags
}

resource "aws_route" "igw" {
    route_table_id = data.aws_vpc.lb_vpc.main_route_table_id
    destination_cidr_block = "0.0.0.0/0"
    egress_only_gateway_id = aws_egress_only_internet_gateway.internet_gateway.id
}