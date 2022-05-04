## GCP CloudFunction Terraform Module

Terraform module to deploy a cloud function to a GCP project.
Source code is zipped and uploaded to a specified bucket before being imported into an HTTP trigger cloud function.

By default the python37 runtime is used, but this can be changed as needed.

### Required

* `gcp_project` : GCP Project to deploy function to
* `bucket_name` : Bucket name to be used to store code before import to Cloud Functions, must exist
* `function_name` : Name of your function
* `function_description` : Description of function
* `function_source_dir` : Path to function source code
* `service_account` : SA email address that will run the function
* `vpc_connector` : VPC Connector self link, to further restrict access

#### bucket_name

Bucket should exist and the name passed to this module. The reason being you could use one bucket to store multiple zip files of various cloud functions... no obvious reason to have a separate bucket per function.

### Example

```
resource "google_storage_bucket" "source_bucket" {
  name          = var.bucket_name
  location      = "EU"
  force_destroy = true
}

module "cloudfunction" {
  source = "path/to/module"

  gcp_project          = "GCP_PROJECT"
  bucket_name          = google_storage_bucket.source_bucket.name
  function_name        = "hello_world"
  function_description = "Say Hello to the world."
  function_source_dir  = "path/to/function/source"
  service_account      = "function_runner@project_id.iam.gserviceaccount.com"
}
```
