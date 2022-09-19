# EC2 Complete
output "ec2_complete_id" {
  description = "The ID of the instance"
  value       = module.ec2_complete.id
}

output "ec2_complete_arn" {
  description = "The ARN of the instance"
  value       = module.ec2_complete.arn
}

output "ec2_complete_instance_state" {
  description = "The state of the instance. One of: `pending`, `running`, `shutting-down`, `terminated`, `stopping`, `stopped`"
  value       = module.ec2_complete.instance_state
}

output "ec2_complete_public_dns" {
  description = "The public DNS name assigned to the instance. For EC2-VPC, this is only available if you've enabled DNS hostnames for your VPC"
  value       = module.ec2_complete.public_dns
}

output "ec2_complete_public_ip" {
  description = "The public IP address assigned to the instance, if applicable. NOTE: If you are using an aws_eip with your instance, you should refer to the EIP's address directly and not use `public_ip` as this field will change after the EIP is attached"
  value       = module.ec2_complete.public_ip
}

output "ec2_complete_tags_all" {
  description = "A map of tags assigned to the resource, including those inherited from the provider default_tags configuration block"
  value       = module.ec2_complete.tags_all
}


