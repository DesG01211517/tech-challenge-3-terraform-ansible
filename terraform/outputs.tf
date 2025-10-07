output "instance_public_ip" {
  value       = aws_instance.web.public_ip
  description = "Public IP of the EC2 instance"
}

output "instance_public_dns" {
  value       = aws_instance.web.public_dns
  description = "Public DNS of the EC2 instance"
}

output "security_group_id" {
  value       = aws_security_group.web_sg.id
  description = "Security group ID"
}

output "s3_bucket_name" {
  value       = aws_s3_bucket.artifact_bucket.bucket
  description = "S3 bucket name"
}
