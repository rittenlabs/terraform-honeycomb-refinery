/*

Copyright (c) 2023 - Present. Ritten. All rights reserved
Use of this source code is governed by a MIT license that can be found in the LICENSE file.

*/

data "google_compute_network" "primary_network" {
  name = var.vpc
}

data "google_compute_subnetwork" "primary_subnetwork" {
  name   = var.subnet
  region = var.region
}

data "google_secret_manager_secret_version" "honeycomb_refinery_api_key" {
  secret = var.api_key_secret_name
}

data "google_secret_manager_secret_version" "honeycomb_refinery_metrics_api_key" {
  secret = var.metrics_api_key_secret_name
}
