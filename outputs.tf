output "apache_public_ips" {
  description = "Public IPs of Apache instances"
  value       = aws_instance.apache[*].public_ip
}

output "nginx_public_ips" {
  description = "Public IPs of Nginx instances"
  value       = aws_instance.nginx[*].public_ip
}

output "all_public_ips" {
  description = "All public IPs (Apache + Nginx)"
  value       = concat(aws_instance.apache[*].public_ip, aws_instance.nginx[*].public_ip)
}

output "apache_instance_ids" {
  description = "Instance IDs of Apache servers"
  value       = aws_instance.apache[*].id
}

output "nginx_instance_ids" {
  description = "Instance IDs of Nginx servers"
  value       = aws_instance.nginx[*].id
}
