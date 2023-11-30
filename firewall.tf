/*

Copyright (c) 2023 - Present. Ritten. All rights reserved
Use of this source code is governed by a MIT license that can be found in the LICENSE file.

*/

# NOTE: To actually send data to refinery you will need to add more firewall rules accordingly

# enable communication between refinery instances and with redis
resource "google_compute_firewall" "refinery" {
  name    = "refinery-redis-firewall-rule"
  project = var.project_id
  network = data.google_compute_network.primary_network.id
  allow {
    protocol = "tcp"
    ports = [
      8080, 8081, 6379
    ]
  }
  source_tags = ["refinery"]
  target_tags = ["refinery"]
}
