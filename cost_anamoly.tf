resource "aws_ce_anomaly_detector" "service_monitor" {
  name         = "innervex-technologies-service-anomaly-detector"
  monitor_type = "DIMENSIONAL"

  specification = jsonencode({
    Dimension = "SERVICE"
  })

  tags = {
    Name          = "innervex-technologies-anomaly-detector"
    Environment   = "PROD"
    Implementedby = "Workmates"
    Managedby     = "Workmates"
    Project       = "Innervex-Technologies"
  }
}

resource "aws_ce_anomaly_subscription" "service_subscription" {
  name      = "innervex-technologies-anomaly-subscription"
  frequency = "DAILY"

  monitor_arn_list = [
    aws_ce_anomaly_detector.service_monitor.arn
  ]

  subscriber {
    type    = "EMAIL"
    address = "impl@cloudworkmates.com"
  }

  subscriber {
    type    = "EMAIL"
    address = "support@cloudworkmates.com"
  }

  threshold_expression {
    and {
      dimension {
        key           = "ANOMALY_TOTAL_IMPACT_ABSOLUTE"
        values        = [var.anomaly_threshold]
        match_options = ["GREATER_THAN_OR_EQUAL"]
      }
    }
  }

  tags = {
    Name          = "innervex-technologies-anomaly-subscription"
    Environment   = "PROD"
    Implementedby = "Workmates"
    Managedby     = "Workmates"
    Project       = "Innervex-Technologies"
  }
}