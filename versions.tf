/*

Copyright (c) 2023 - Present. Ritten. All rights reserved
Use of this source code is governed by a MIT license that can be found in the LICENSE file.

*/

terraform {
  required_version = ">=0.13.0"

  required_providers {
    google-beta = {
      version = ">= 4.84.0, < 6"
    }
    google = {
      version = ">= 4.84.0, < 6"
    }
  }
}
