provider "aws" {
  region = "${var.region}"
}

variable "region" {
  description = "virginia"
  default     = "us-east-1"
}