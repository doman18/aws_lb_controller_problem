variable "cluster_name" {
  default = "demo-cluster"
}

variable "cluster_version" {
  default = "1.25"
}

variable "region" {
  description = "The aws region. https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-regions-availability-zones.html"
  type        = string
  default     = "eu-central-1"
}