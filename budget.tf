resource "aws_budgets_budget" "monthly_cost_budget" {
  name         = "${var.Project_Name}-monthly-budget"
  budget_type  = "COST"
  limit_amount = var.budget_amount
  limit_unit   = "USD"
  time_unit    = "MONTHLY"
  time_period_start = "2026-01-01_00:00"

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                 = 80
    threshold_type            = "PERCENTAGE"
    notification_type         = "ACTUAL"
    subscriber_email_addresses = [
      "impl@cloudworkmates.com",
      "support@cloudworkmates.com"
    ]
  }

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                 = 90
    threshold_type            = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = [
      "impl@cloudworkmates.com",
      "support@cloudworkmates.com"
    ]
  }

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                 = 100
    threshold_type            = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = [
      "impl@cloudworkmates.com",
      "support@cloudworkmates.com"
    ]
  }

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                 = 120
    threshold_type            = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = [
      "impl@cloudworkmates.com",
      "support@cloudworkmates.com"
    ]
  }
}