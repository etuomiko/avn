variable "aiven_api_token" {}
variable "aiven_card_id" {}
variable "aiven_project_name" {}

terraform {
  required_providers {
    aiven = {
      source = "aiven/aiven"
      version = "2.1.6"
    }
  }
}

# Initialize provider. No other config options than api_token
provider "aiven" {
  api_token = var.aiven_api_token
}

# Project
resource "aiven_project" "sample" {
  project = var.aiven_project_name
  card_id = var.aiven_card_id
}

# Kafka service running in Google
resource "aiven_service" "kafkagoogle" {
  project                 = aiven_project.sample.project
  cloud_name              = "google-europe-west1"
  plan                    = "business-4"
  service_name            = "kafkagoogle"
  service_type            = "kafka"
  maintenance_window_dow  = "monday"
  maintenance_window_time = "10:00:00"
  kafka_user_config {
    kafka_connect = true
    kafka_rest    = true
    kafka_version = "2.7"
    kafka {
      group_max_session_timeout_ms = 70000
      log_retention_bytes          = 1000000000
    }
  }
}

# Topic for Kafka running in Google
resource "aiven_kafka_topic" "googletopic" {
  project         = aiven_project.sample.project
  service_name    = aiven_service.kafkagoogle.service_name
  topic_name      = "googletopic"
  partitions      = 3
  replication     = 2
  config {
    retention_bytes = 1000000000
  }
}

# User for Kafka running in Google
resource "aiven_service_user" "kafkagoogle_a" {
  project      = aiven_project.sample.project
  service_name = aiven_service.kafkagoogle.service_name
  username     = "kafkagoogle_a"
}

# ACL for Kafka running in Google
resource "aiven_kafka_acl" "kafkagoogle_acl" {
  project      = aiven_project.sample.project
  service_name = aiven_service.kafkagoogle.service_name
  username     = "kafkagoogle_*"
  permission   = "read"
  topic        = "*"
}


# Kafka service running in Azure (note runs in GCP though)
resource "aiven_service" "kafkaazure" {
  project                 = aiven_project.sample.project
  cloud_name              = "google-europe-west1"
  plan                    = "business-4"
  service_name            = "kafkaazure"
  service_type            = "kafka"
  maintenance_window_dow  = "monday"
  maintenance_window_time = "10:00:00"
  kafka_user_config {
    kafka_connect = true
    kafka_rest    = true
    kafka_version = "2.7"
    kafka {
      group_max_session_timeout_ms = 70000
      log_retention_bytes          = 1000000000
    }
  }
}

# Topic for Kafka running in Azure
resource "aiven_kafka_topic" "azuretopic" {
  project         = aiven_project.sample.project
  service_name    = aiven_service.kafkaazure.service_name
  topic_name      = "azuretopic"
  partitions      = 3
  replication     = 2
  config {
    retention_bytes = 1000000000
  }
}

# User for Kafka running in Azure
resource "aiven_service_user" "kafkaazure_a" {
  project      = aiven_project.sample.project
  service_name = aiven_service.kafkaazure.service_name
  username     = "kafkaazure_a"
}

# ACL for Kafka running in Azure
resource "aiven_kafka_acl" "kafkaazure_acl" {
  project      = aiven_project.sample.project
  service_name = aiven_service.kafkaazure.service_name
  username     = "kafkaazure_*"
  permission   = "read"
  topic        = "*"
}
