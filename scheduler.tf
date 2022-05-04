# Cloud Scheduler requires an App Engine project in the required region.
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloud_scheduler_job
# If you have multiple functions to schedule create an app elsewhere in TF rather than create multiple.

resource "google_app_engine_application" "app" {
  count = var.trigger_type == "scheduled" && var.appengine_required ? 1 : 0

  project     = var.gcp_project
  location_id = var.gcp_region
}

resource "google_pubsub_topic" "cf_trigger" {
  count = var.trigger_type == "scheduled" ? 1 : 0

  name    = var.function_name
  project = var.gcp_project
}

resource "google_cloud_scheduler_job" "job" {
  count = var.trigger_type == "scheduled" ? 1 : 0

  name        = var.function_name
  project     = var.gcp_project
  region      = var.gcp_region
  description = "Run ${var.function_name} function regularly."
  schedule    = var.schedule_cron
  time_zone   = "Europe/London"

  pubsub_target {
    topic_name = google_pubsub_topic.cf_trigger[0].id
    data       = base64encode("trigger")
  }
}
