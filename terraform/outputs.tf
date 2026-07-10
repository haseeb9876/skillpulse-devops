output "instance_id" {
  description = "EC2 instance ID."
  value       = aws_instance.skillpulse.id
}

output "public_ip" {
  description = "Public IPv4 address of the SkillPulse server."
  value       = aws_instance.skillpulse.public_ip
}

output "public_dns" {
  description = "Public DNS name of the SkillPulse server."
  value       = aws_instance.skillpulse.public_dns
}

output "application_url" {
  description = "Public HTTP URL of the SkillPulse application."
  value       = "http://${aws_instance.skillpulse.public_ip}"
}

output "ssh_command" {
  description = "Command used to connect to the server from Windows PowerShell."
  value       = "ssh -i ~/.ssh/skillpulse-ec2 ubuntu@${aws_instance.skillpulse.public_ip}"
}

output "ubuntu_ami_id" {
  description = "Official Ubuntu AMI selected dynamically by Terraform."
  value       = data.aws_ami.ubuntu.id
}
