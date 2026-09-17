output "vpc_id" {
  value = aws_vpc.main.id
}

output "alb_dns_name" {
  value = aws_lb.app.dns_name
}

output "ec2_private_ip" {
  value = aws_instance.app.private_ip
}

output "rds_endpoint" {
  value = aws_db_instance.postgres.address
}