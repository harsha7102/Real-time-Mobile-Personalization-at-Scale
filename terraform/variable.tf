variable "confluent_cloud_api_key" {
description = "Confluent Cloud API Key (also referred as Cloud API ID)"
type        = string
sensitive = true
default = "Add your Cloud API Key"
}

variable "confluent_cloud_api_secret" {
description = "Confluent Cloud API Key (also referred as Cloud API Secret)"
type        = string
sensitive = true
default = "Add you Cloud Secret key"
}

