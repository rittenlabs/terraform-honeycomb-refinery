# terraform-honeycomb-refinery

This module allows you to create a Managed Instance Group running Honeycomb Refinery and a single compute instance running a small Redis server to support the Refinery instances.

We expect that you will already have a VPC and Subnet created where these instances will be instantiated. You will also need to have two secrets created in advance containing Honeycomb API keys.

## Compatibility

This module is meant for use with Terraform 0.13+ and tested using Terraform 1.0+. If you find incompatibilities using Terraform >=0.13, please open an issue.

## Usage

## Documentation

```hcl
module "honeycomb_refinery" {
    source = "github.com/rittenlabs/terraform-honeycomb-refinery"

    honeycomb_refinery_verison  = "latest"
    project_id                  = "my-project"
    vpc                         = "vpc-primary"
    subnet                      = "subnet-primary"
    region                      = "us-east1"
    zone                        = "us-east1-b"
    api_key_secret_name         = "honeycomb-refinery-api-key"
    metrics_api_key_secret_name = "honeycomb-refinery-metrics-api-key"
}

```

Note: Once deployed you will likely need to make updates to your firewall in order to actually send trace and metrics data to Refinery.

### Inputs

| Name                        | Description                                                                                   | Default                            | Required |
| --------------------------- | --------------------------------------------------------------------------------------------- | ---------------------------------- | -------- |
| honeycomb_refinery_verison  | Version of Honeycomb Refinery to deploy                                                       | latest                             | yes      |
| project_id                  | GCP Project ID                                                                                | my-project                         | yes      |
| vpc                         | Name of an existing vpc where the resources will be created                                   | vpc-primary                        | yes      |
| subnet                      | Name of a subnet within the existing vpc where the resources will be created                  | subnet-primary                     | yes      |
| region                      | Region where the subnet is located                                                            | us-east1                           | yes      |
| zone                        | A zone within the region where resources will be created                                      | us-east1-b                         | yes      |
| api_key_secret_name         | Name of a GCP Secret containing the honeycomb api key to be used by refinery for trace data   | honeycomb-refinery-api-key         | yes      |
| metrics_api_key_secret_name | Name of a GCP Secret containing the honeycomb api key to be used by refinery for metrics data | honeycomb-refinery-metrics-api-key | yes      |
