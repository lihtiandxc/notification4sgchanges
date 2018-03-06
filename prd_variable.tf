provider "aws" {
  alias  = "virginia"
  region = "${var.region}"
}

variable "region" {
  default     = "us-east-1"
}
