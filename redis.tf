/*

Copyright (c) 2023 - Present. Ritten. All rights reserved
Use of this source code is governed by a MIT license that can be found in the LICENSE file.

*/

module "gce_container_redis" {
  source  = "terraform-google-modules/container-vm/google"
  version = "3.1.0"

  container = {
    image = "us-docker.pkg.dev/ritten-ops/external/redis:7.2"
  }
  restart_policy = "OnFailure"
}

resource "google_compute_instance" "redis" {
  project      = var.project_id
  name         = "honeycomb-refinery-redis"
  machine_type = "n1-standard-1"
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = module.gce_container_redis.source_image
    }
  }

  network_interface {
    subnetwork_project = var.project_id
    subnetwork         = data.google_compute_subnetwork.primary_subnetwork.id
  }

  tags = ["refinery"]

  metadata = {
    gce-container-declaration = module.gce_container_redis.metadata_value
    google-logging-enabled    = "true"
    google-monitoring-enabled = "true"
  }

  labels = { container-vm = module.gce_container_redis.vm_container_label }

  service_account {
    email = google_service_account.honeycomb_refinery.email
    scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]
  }
}
