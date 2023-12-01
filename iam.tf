/*

Copyright (c) 2023 - Present. Ritten. All rights reserved
Use of this source code is governed by a MIT license that can be found in the LICENSE file.

*/

resource "google_service_account" "honeycomb_refinery" {
  account_id   = "honeycomb-refinery"
  project      = var.project_id
  display_name = "Honeycomb Refinery"
}

resource "google_project_iam_member" "honeycomb_refinery_manager_permissions" {
  project = var.project_id
  role    = "roles/secretmanager.secretAccessor"
  member  = "serviceAccount:${google_service_account.honeycomb_refinery.email}"
}
