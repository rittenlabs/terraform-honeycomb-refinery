/*

Copyright (c) 2023 - Present. Ritten. All rights reserved
Use of this source code is governed by a MIT license that can be found in the LICENSE file.

*/

provider "google" {
  project = var.project_id
  region  = var.region
}

provider "google-beta" {
  project = var.project_id
  region  = var.region
}

terraform {
  required_version = "~> 1.6.2"

  required_providers {
    google-beta = {
      version = "~> 4.84.0"
    }
    google = {
      version = "~> 4.84.0"
    }
  }
}
