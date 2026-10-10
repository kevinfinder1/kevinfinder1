terraform {
  required_providers {
    dynatrace = {
      source  = "dynatrace-oss/dynatrace"
      version = "~> 1.80"
    }
  }
}

# Alerta auto-adaptativa de uso de memoria en hosts.
# Davis aprende la línea base por host y dispara cuando el uso real
# se desvía del comportamiento esperado (sin umbral fijo).
resource "dynatrace_metric_events" "host_memory_auto_adaptive" {
  enabled                    = true
  summary                    = "Uso anómalo de memoria en host"
  event_template {
    title       = "Memoria anómala en {dims:dt.entity.host}"
    description = "El uso de memoria del host {dims:dt.entity.host} se desvía de su línea base aprendida por Davis."
    event_type  = "CUSTOM_ALERT"
    davis_merge = true
  }
  model_properties {
    type               = "AUTO_ADAPTIVE"
    alert_condition    = "ABOVE"
    alert_on_no_data   = false
    dealerting_samples = 5
    samples            = 5
    violating_samples  = 3
  }
  query_definition {
    type            = "METRIC_KEY"
    metric_key      = "dt.host.memory.used"
    dimension_filter = []
    aggregation     = "AVG"
  }
}
