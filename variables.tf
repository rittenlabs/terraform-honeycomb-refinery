/*

Copyright (c) 2023 - Present. Ritten. All rights reserved
Use of this source code is governed by a MIT license that can be found in the LICENSE file.

*/

variable "honeycomb_refinery_verison" {
  default     = "latest"
  type        = string
  description = "Version of Honeycomb Refinery to deploy"
}

variable "config_file_path" {
  default     = ""
  type        = string
  description = "Path to the Refinery config.yaml file"
}

variable "rules_file_path" {
  default     = ""
  type        = string
  description = "Path to the Refinery rules.yaml file"
}

variable "refinery_instance_count" {
  default     = 1
  type        = number
  description = "The number of Honeycomb Refinery Instance to run"
}

variable "project_id" {
  default     = "my-project"
  type        = string
  description = "GCP Project ID"
}

variable "vpc" {
  default     = "vpc-primary"
  type        = string
  description = "Name of an existing vpc where the resources will be created"
}

variable "subnet" {
  default     = "subnet-primary"
  type        = string
  description = "Name of a subnet within the existing vpc where the resources will be created"
}

variable "region" {
  default     = "us-east1"
  type        = string
  description = "Region where the subnet is located"
}

variable "zone" {
  default     = "us-east1-b"
  type        = string
  description = "A zone within the region where resources will be created"
}

variable "api_key_secret_name" {
  default     = "honeycomb-refinery-api-key"
  type        = string
  description = "Name of a GCP Secret containing the honeycomb api key to be used by refinery for trace data"
}

variable "metrics_api_key_secret_name" {
  default     = "honeycomb-refinery-metrics-api-key"
  type        = string
  description = "Name of a GCP Secret containing the honeycomb api key to be used by refinery for metrics data"
}
