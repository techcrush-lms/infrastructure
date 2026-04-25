# --- Cross-Region VPC Peering (us-east-1 <-> eu-west-1) ---

# 1. Requester side (us-east-1)
resource "aws_vpc_peering_connection" "dev_to_prod" {
  vpc_id      = data.aws_vpc.dev_default.id
  peer_vpc_id = data.aws_vpc.prod_selected.id
  peer_region = var.prod_region
  auto_accept = false

  tags = {
    Name = "dev-to-prod-peering"
  }
}

# 2. Accepter side (eu-west-1)
resource "aws_vpc_peering_connection_accepter" "prod_accepter" {
  provider                  = aws.prod
  vpc_peering_connection_id = aws_vpc_peering_connection.dev_to_prod.id
  auto_accept               = true

  tags = {
    Name = "prod-accepter"
  }
}

# 3. Routing from Dev (us-east-1) to Production (eu-west-1)
resource "aws_route" "dev_to_prod" {
  route_table_id            = data.aws_route_table.dev_default.id
  destination_cidr_block    = data.aws_vpc.prod_selected.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.dev_to_prod.id
}

# 4. Routing from Production (eu-west-1) to Dev (us-east-1)
resource "aws_route" "prod_to_dev" {
  provider                  = aws.prod
  route_table_id            = data.aws_route_table.prod_selected.id
  destination_cidr_block    = data.aws_vpc.dev_default.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.dev_to_prod.id
}
