/*

Copyright (c) 2023 - Present. Ritten. All rights reserved
Use of this source code is governed by a MIT license that can be found in the LICENSE file.

*/

locals {
  refinery_config_path = "/etc/refinery"
  source_config_path   = coalesce(var.config_file_path, "${path.module}/config/config.yaml")
  source_rules_path    = coalesce(var.rules_file_path, "${path.module}/config/rules.yaml")

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
        mountPath = local.refinery_config_path
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
        path = local.refinery_config_path
      }
    },
  ]
  restart_policy = "OnFailure"
}

module "refinery_instance_template" {
  source         = "terraform-google-modules/vm/google//modules/instance_template"
  version        = "10.1.1"
  name_prefix    = "refinery-instance-template"
  project_id     = var.project_id
  machine_type   = "n1-standard-1"
  metadata       = merge(local.additional_metadata, { "gce-container-declaration" = module.refinery_gce_container.metadata_value, "project-id" = var.project_id })
  startup_script = templatefile("${path.module}/config/startup.sh.tpl", { config_path = local.refinery_config_path, source_config_path = local.source_config_path, source_rules_path = local.source_rules_path })
  service_account = {
    email  = google_service_account.honeycomb_refinery.email
    scopes = ["cloud-platform"]
  }
  tags = ["refinery"]

  /* network */
  subnetwork = data.google_compute_subnetwork.primary_subnetwork.id

  /* image */
  source_image_project = "cos-cloud"
  source_image_family  = "cos-stable"
  source_image         = reverse(split("/", module.refinery_gce_container.source_image))[0]

  /* disks */
  disk_size_gb = 10
  disk_type    = "pd-ssd"
  auto_delete  = true
}

module "refinery_mig" {
  source            = "terraform-google-modules/vm/google//modules/mig"
  version           = "10.1.1"
  project_id        = var.project_id
  hostname          = "honeycomb-refinery"
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

  /* update */
  # TODO: replace max surge and unavailable with vars (or possibly this full policy)
  update_policy = {
    type                           = "PROACTIVE"
    instance_redistribution_type   = "PROACTIVE"
    minimal_action                 = "REPLACE"
    most_disruptive_allowed_action = "REPLACE"
    max_surge_fixed                = 2
    max_unavailable_fixed          = 2
    replacement_method             = "SUBSTITUTE"
  }
}
