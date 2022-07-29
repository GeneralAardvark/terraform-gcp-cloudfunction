variable "gcp_project" {
  type        = string
  description = "Project to deploy function to"
}

variable "gcp_region" {
  type        = string
  description = "GCP Region to deploy function to"
  default     = "europe-west2"
}

variable "bucket_name" {
  type        = string
  description = "Name of an existing bucket to upload functions source to be available to function import"
}

variable "function_name" {
  type        = string
  description = "Name of your function"
}

variable "function_memory" {
  type        = number
  description = "Amount of memory in MB to assign to the function"
  default     = 128
}

variable "function_runtime" {
  type        = string
  description = "Function runtime, eg. python37, nodejs10 etc"
  default     = "python37"
}

variable "function_timeout" {
  type    = number
  default = 300
}

variable "function_description" {
  type        = string
  description = "Description of the function"
}

variable "function_source_dir" {
  type        = string
  description = "Path to directory containing function source code"
}

variable "service_account" {
  type        = string
  description = "Service account that will run the function."
  default     = ""
}

variable "trigger_type" {
  type        = string
  description = "The type of trigger to use for the function, one of http, scheduled, pubsub or gcs."

  validation {
    condition     = contains(["http", "scheduled", "pubsub", "gcs"], var.trigger_type)
    error_message = "The trigger_type must be one of http, scheduled, pubsub or gcs."
  }
}

variable "schedule_cron" {
  type        = string
  description = "Schedule function is to be invoked, crontab format"
  default     = "0 * * * *" # Every hour on the hour.
}

variable "pubsub_topic_name" {
  type        = string
  description = "A pubsub topic to trigger the function"
  default     = ""
}

variable "gcs_trigger_bucket_name" {
  type        = string
  description = "Bucket to monitor for change to trigger function"
  default     = ""
}

variable "appengine_required" {
  type        = bool
  description = "If there are no other app engine applications in this project and region, you will need one for scheduler to function."
  default     = false
}

variable "vpc_connector" {
  type    = string
  default = null
}

variable "vpc_egress_option" {
  type    = string
  default = null
}

variable "environment_secrets" {
  type    = list(object({
    key     = string
    secret  = string
    version = string
  }))
  default = []
}
