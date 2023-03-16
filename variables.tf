variable "cluster_version" {
  default = "1.24"
}

variable "region" {
  description = "The aws region. https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-regions-availability-zones.html"
  type        = string
  default     = "eu-central-1"
}

variable "projname_short" {
    description = "Name to be used on all the resources as identifier. e.g. Project name, Application name"
    type    = string
    default = "ingress-problem"
}