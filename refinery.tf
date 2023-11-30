/*

Copyright (c) 2023 - Present. Ritten. All rights reserved
Use of this source code is governed by a MIT license that can be found in the LICENSE file.

*/

locals {
  config_path = "/etc/refinery/"

  additional_metadata = {
    "api-key"         = "honeycomb-refinery-api-key"
    "metrics-api-key" = "honeycomb-refinery-metrics-api-key"
  }
}


module "refinery_gce_container" {
  source  = "terraform-google-modules/container-vm/google"
  version = "3.1.0"
  container = {
    image = "honeycombio/refinery:${var.honeycomb_refinery_verison}"
    volumeMounts = [
      {
        mountPath = local.config_path
        name      = "config"
        readOnly  = true
      },
    ]
    env = [
      {
        name  = "REFINERY_HONEYCOMB_API_KEY"
        value = data.google_secret_manager_secret_version.honeycomb_refinery_api_key.secret_data
      },
      {
        name  = "REFINERY_OTEL_METRICS_API_KEY"
        value = data.google_secret_manager_secret_version.honeycomb_refinery_metrics_api_key.secret_data
      },
      {
        name  = "REFINERY_REDIS_HOST"
        value = format("%s:6379", google_compute_instance.redis.network_interface.0.network_ip)
      },
    ]
  }
  volumes = [
    {
      name = "config"
      hostPath = {
        path = local.config_path
      }
    },
  ]
  restart_policy = "OnFailure"
}

module "refinery_instance_template" {
  source         = "terraform-google-modules/vm/google//modules/instance_template"
  version        = "10.1.1"
  name_prefix    = "refinery-${var.env_name}-instance-template"
  project_id     = var.project_id
  machine_type   = "n1-standard-1"
  labels         = local.labels
  metadata       = merge(local.additional_metadata, { "gce-container-declaration" = module.refinery_gce_container.metadata_value, "project-id" = var.project_id })
  startup_script = templatefile("${path.module}/refinery/startup.sh.tpl", { config_path = local.config_path })
  service_account = {
    email  = google_service_account.honeycomb_refinery.email
    scopes = ["cloud-platform"]
  }
  tags = ["refinery"]

  /* network */
  subnetwork = data.google_compute_subnetwork.primary_subnetwork.id
  # can_ip_forward = var.can_ip_forward

  /* image */
  source_image_project = "cos-cloud"
  source_image_family  = "cos-stable"
  source_image         = reverse(split("/", module.refinery_gce_container.source_image))[0]

  /* disks */
  disk_size_gb = 10
  disk_type    = "pd-ssd"
  disk_labels  = local.labels
  auto_delete  = true
}

module "refinery_mig" {
  source            = "terraform-google-modules/vm/google//modules/mig"
  version           = "10.1.1"
  project_id        = var.project_id
  hostname          = "refinery-${var.env_name}"
  region            = var.region
  instance_template = module.refinery_instance_template.self_link
  target_size       = 1
  named_ports = [
    {
      name = "http",
      port = 8080
    },
    {
      name = "peer-listener",
      port = 8081
    },
  ]

  /* autoscaler */
  autoscaling_enabled = true
  max_replicas        = 3
  min_replicas        = 1
  cooldown_period     = 60
  autoscaling_cpu = [{
    target            = 0.75
    predictive_method = "OPTIMIZE_AVAILABILITY"
  }]
}
