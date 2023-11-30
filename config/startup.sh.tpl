/*

Copyright (c) 2023 - Present. Ritten. All rights reserved
Use of this source code is governed by a MIT license that can be found in the LICENSE file.

*/

#!/usr/bin/env bash

# Generates a config file with templated values.
#
# Terraform interpolation uses standard shell interpolation syntax ($).
# So shell interpolation inside a Terraform template must be escaped ($$).
# Command substitution does not need escaping ($).

set -o errexit -o nounset -o pipefail -o posix

# Get the IP Address to be used by the config for registration of each instance
INSTANCE_IP=$(hostname -i)

# Create the Refinery config directory
mkdir -p "$(dirname "${config_path}")"

# Create the Refinery config file
cat > "${config_path}/refinery.yaml" << EOF
${file("config/config.yaml")}
EOF

# Create the Refinery rules file
cat > "${config_path}/rules.yaml" << EOF
${file("config/rules.yaml")}
EOF

