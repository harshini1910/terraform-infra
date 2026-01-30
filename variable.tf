variable "region" {
  description = "AWS region to deploy resources into"
  type        = string
  default     = "ap-south-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "key_name" {
  description = "new-pem"
  type        = string
}

variable "ssh_cidr" {
  description = "CIDR block allowed to SSH (22). For testing you can use 0.0.0.0/0, but better: your_ip/32"
  type        = string
  default     = "0.0.0.0/0"
}

variable "tags_project" {
  description = "Common project tag"
  type        = string
  default     = "jenkins-terraform-ansible"
}
