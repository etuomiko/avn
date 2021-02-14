# Monitoring InfluxDB service
resource "aiven_service" "monitorinflux" {
  project                 = aiven_project.sample.project
  cloud_name              = "google-europe-west1"
  plan                    = "startup-4"
  service_name            = "monitorinflux"
  service_type            = "influxdb"
  maintenance_window_dow  = "monday"
  maintenance_window_time = "11:00:00"
  influxdb_user_config {
    ip_filter = ["0.0.0.0/0"]
  }
}

# Send metrics from Kafka running in Google to InfluxDB
resource "aiven_service_integration" "kafkagoogle_metrics" {
  project                  = aiven_project.sample.project
  integration_type         = "metrics"
  source_service_name      = aiven_service.kafkagoogle.service_name
  destination_service_name = aiven_service.monitorinflux.service_name
}

# Send metrics from Kafka running in Azure to InfluxDB
resource "aiven_service_integration" "kafkaazure_metrics" {
  project                  = aiven_project.sample.project
  integration_type         = "metrics"
  source_service_name      = aiven_service.kafkaazure.service_name
  destination_service_name = aiven_service.monitorinflux.service_name
}

# Send metrics from Mirrormaker running in Google to InfluxDB
resource "aiven_service_integration" "mmgoogle_metrics" {
  project                  = aiven_project.sample.project
  integration_type         = "metrics"
  source_service_name      = aiven_kafka_mirrormaker.mmgoogle.service_name
  destination_service_name = aiven_service.monitorinflux.service_name
}

# Grafana monitoring service
resource "aiven_grafana" "monitorgrafana" {
  project = aiven_project.sample.project
  cloud_name = "google-europe-west1"
  plan = "startup-4"
  service_name = "monitorgrafana"
  grafana_user_config {
    public_access {
      grafana = true
    }
  }
}

data "aiven_service_component" "grafana_public" {
  project = aiven_project.sample.project
  service_name = aiven_grafana.monitorgrafana.service_name
  component = "grafana"
  route = "public"

  depends_on = [
    aiven_grafana.monitorgrafana
  ]
}

# Dashboards for Kafka and Mirrormaker 2.0 services
resource "aiven_service_integration" "samplegrafana_dashboards" {
  project                  = aiven_project.sample.project
  integration_type         = "dashboard"
  source_service_name      = aiven_grafana.monitorgrafana.service_name
  destination_service_name = aiven_service.monitorinflux.service_name
}

output "grafana_public" {
  value = "${data.aiven_service_component.grafana_public.host}:${data.aiven_service_component.grafana_public.port}"
}
