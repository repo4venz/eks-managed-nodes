output "aws_subnets_public_ids" {
  value   = aws_subnet.public_subnet.*.id
}

output "aws_subnets_private_ids" {
  value   = aws_subnet.private_subnet.*.id
}

output "vpc_id" {
  value  = aws_vpc.main_vpc.id
}

