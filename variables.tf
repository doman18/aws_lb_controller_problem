variable "cluster_name" {
  default = "demo2"
}

variable "cluster_version" {
  default = "1.22"
}

variable "region" {
  description = "The aws region. https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-regions-availability-zones.html"
  type        = string
  default     = "us-east-1"
}