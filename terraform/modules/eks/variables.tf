variable "cluster_name" {
  description = "Base name for the cluster (environment is appended)"
  type        = string
}

variable "environment" {
  description = "Environment name (dev/qa/prod)"
  type        = string
}

variable "kubernetes_version" {
  description = "EKS Kubernetes version"
  type        = string
  default     = "1.30"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "Availability zones to spread subnets across"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "CIDRs for the private (worker) subnets"
  type        = list(string)
}

variable "public_subnet_cidrs" {
  description = "CIDRs for the public (NAT/LB) subnets"
  type        = list(string)
}

variable "node_instance_types" {
  description = "Instance types for the managed node group"
  type        = list(string)
  default     = ["t3.medium"]
}

variable "node_capacity_type" {
  description = "ON_DEMAND or SPOT"
  type        = string
  default     = "ON_DEMAND"
}

variable "node_min_size" {
  type    = number
  default = 1
}

variable "node_max_size" {
  type    = number
  default = 4
}

variable "node_desired_size" {
  type    = number
  default = 2
}

variable "region_hint" {
  description = "Region used only to render the kubectl helper output"
  type        = string
  default     = "ap-south-1"
}

variable "tags" {
  description = "Additional tags"
  type        = map(string)
  default     = {}
}
