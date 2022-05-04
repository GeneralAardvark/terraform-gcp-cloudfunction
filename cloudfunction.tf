resource "random_id" "source_filename_suffix" {
  byte_length = 8
}

data "archive_file" "source" {
  type        = "zip"
  output_path = "${var.function_name}_${random_id.source_filename_suffix.hex}.zip"
  source_dir  = var.function_source_dir
}

resource "google_storage_bucket_object" "source_archive" {
  name   = "${var.function_name}-${substr(filemd5(data.archive_file.source.output_path), 26, 6)}.zip"
  bucket = var.bucket_name
  source = data.archive_file.source.output_path
}

resource "google_pubsub_topic" "pubsub_topic" {
  count = var.trigger_type == "pubsub" ? 1 : 0

  project = var.gcp_project
  name    = var.pubsub_topic_name
}

locals {
  event_trigger = var.trigger_type == "http" ? [] : [var.trigger_type]
  event_type = {
    "gcs"       = "google.storage.object.finalize",
    "scheduled" = "google.pubsub.topic.publish",
    "pubsub"    = "google.pubsub.topic.publish"
  }
  event_resource = {
    "gcs"       = var.gcs_trigger_bucket_name,
    "scheduled" = var.trigger_type == "scheduled" ? google_pubsub_topic.cf_trigger[0].id : ""
    "pubsub"    = var.trigger_type == "pubsub" ? google_pubsub_topic.pubsub_topic[0].id : ""
  }
}

resource "google_cloudfunctions_function" "function" {
  name        = var.function_name
  description = var.function_description
  runtime     = var.function_runtime
  region      = var.gcp_region
  project     = var.gcp_project

  available_memory_mb   = var.function_memory
  source_archive_bucket = google_storage_bucket_object.source_archive.bucket
  source_archive_object = google_storage_bucket_object.source_archive.name
  entry_point           = var.function_name
  service_account_email = var.service_account
  timeout               = var.function_timeout

  trigger_http = var.trigger_type == "http" ? true : null

  dynamic "event_trigger" {
    for_each = toset(local.event_trigger)
    content {
      event_type = local.event_type[event_trigger.value]
      resource   = local.event_resource[event_trigger.value]
    }
  }
}
