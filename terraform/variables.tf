variable "location" {
  type    = string
  default = "westeurope"
}

variable "env" {
  type    = string
  default = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.env)
    error_message = "env must be dev, staging or prod"
  }
}

variable "app" {
  type    = string
  default = "helloapp"
}

variable "img" {
  type    = string
  default = "nginx:latest"
}

variable "cpu" {
  type    = number
  default = 0.5
}

variable "mem" {
  type    = string
  default = "1Gi"
}

variable "min_inst" {
  type    = number
  default = 1
}

variable "max_inst" {
  type    = number
  default = 3
}
