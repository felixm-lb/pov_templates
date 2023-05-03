resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = data.aws_vpc.lb_vpc.id

  tags = var.tags
}

resource "aws_route" "igw" {
    route_table_id = data.aws_route_table.lb_route_table.id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
}