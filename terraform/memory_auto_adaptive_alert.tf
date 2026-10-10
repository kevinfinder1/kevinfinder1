terraform {
  required_providers {
    dynatrace = {
      source  = "dynatrace-oss/dynatrace"
      version = "~> 1.80"
    }
  }
}

# Alerta auto-adaptativa de uso de memoria por host.
# Davis aprende la línea base de cada host y abre un evento cuando el uso
# se sale de su banda de confianza, sin un umbral fijo.
resource "dynatrace_metric_events" "host_memory_auto_adaptive" {
  enabled                    = true
  summary                    = "OwlTrace - Uso anómalo de memoria en host"
  event_entity_dimension_key = "dt.entity.host"

  event_template {
    title       = "Uso anómalo de memoria en {dims:dt.entity.host.name}"
    description = "El uso de memoria del host {dims:dt.entity.host.name} se salió de la línea base que Davis aprendió para él."
    event_type  = "RESOURCE"
    davis_merge = true
  }

  model_properties {
    type               = "AUTO_ADAPTIVE_THRESHOLD"
    alert_condition    = "ABOVE"
    alert_on_no_data   = false
    samples            = 5
    violating_samples  = 3
    dealerting_samples = 5
    signal_fluctuation = 1
    tolerance          = 4
  }

  query_definition {
    type            = "METRIC_SELECTOR"
    metric_selector = "builtin:host.mem.usage:splitBy(\"dt.entity.host\"):avg"
  }
}
