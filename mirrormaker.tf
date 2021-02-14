# Setup Mirrormaker
resource "aiven_kafka_mirrormaker" "mmgoogle" {
  project = aiven_project.sample.project
  cloud_name = "google-europe-west1"
  plan = "startup-4"
  service_name = "mmgoogle"

  kafka_mirrormaker_user_config {
    ip_filter = [
      "0.0.0.0/0"
    ]

    kafka_mirrormaker {
      refresh_groups_interval_seconds = 600
      refresh_topics_enabled = true
      refresh_topics_interval_seconds = 600
    }
  }
}

# Source integration to Kafka running on Google
resource "aiven_service_integration" "mmi1source" {
  project = aiven_project.sample.project
  integration_type = "kafka_mirrormaker"
  source_service_name = aiven_service.kafkagoogle.service_name
  destination_service_name = aiven_kafka_mirrormaker.mmgoogle.service_name

  kafka_mirrormaker_user_config {
    cluster_alias = "source"
  }
}

# Target integration to Kafka running on Google
resource "aiven_service_integration" "mmitarget" {
  project = aiven_project.sample.project
  integration_type = "kafka_mirrormaker"
  source_service_name = aiven_service.kafkaazure.service_name
  destination_service_name = aiven_kafka_mirrormaker.mmgoogle.service_name

  kafka_mirrormaker_user_config {
    cluster_alias = "target"
  }
}

# Replicated topics
resource "aiven_mirrormaker_replication_flow" "f1" {
  project = aiven_project.sample.project
  service_name = aiven_kafka_mirrormaker.mmgoogle.service_name
  source_cluster = aiven_service.kafkagoogle.service_name
  target_cluster = aiven_service.kafkaazure.service_name
  enable = true

  topics = [
    ".*",
  ]

  topics_blacklist = [
    ".*[\\-\\.]internal",
    ".*\\.replica",
    "__.*"
  ]
}
