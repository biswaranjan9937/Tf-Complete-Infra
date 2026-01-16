# Patch Baseline for Alma Linux (Ubuntu/Alma Linux)
resource "aws_ssm_patch_baseline" "alma_linux_baseline" {
  name             = "CWM_alma_linux-critical-security-baseline"
  description      = "Patch baseline for Alma Linux servers - Critical and Security updates"
  operating_system = "ALMA_LINUX" # Change to: UBUNTU, CENTOS, REDHAT_ENTERPRISE_LINUX, etc.

  approval_rule {
    approve_after_days = 0 # Auto-approve immediately
    compliance_level   = "CRITICAL"

    patch_filter {
      key    = "CLASSIFICATION"
      values = ["Security", "Recommended"]
    }

    patch_filter {
      key    = "SEVERITY"
      values = ["Critical", "Important"]
    }
  }

  tags = {
    Name        = "alma-linux-critical-security-baseline"
    Environment = var.environment
    patch_baseline = "yes"
  }
}
resource "aws_ssm_default_patch_baseline" "alma_linux_default" {
  baseline_id      = aws_ssm_patch_baseline.alma_linux_baseline.id
  operating_system = "ALMA_LINUX"
}

# Patch Baseline for Ubuntu (Ubuntu/Amazon Linux)
resource "aws_ssm_patch_baseline" "ubuntu_baseline" {
  name             = "CWM_ubuntu-critical-security-baseline"
  description      = "Patch baseline for Ubuntu servers - Critical and Security updates"
  operating_system = "UBUNTU" # Change to: UBUNTU, CENTOS, REDHAT_ENTERPRISE_LINUX, etc.
  approval_rule {
    approve_after_days = 0 # Auto-approve immediately
    compliance_level   = "CRITICAL"

    patch_filter {
      key    = "SECTION"
      values = ["All"]
    }

    patch_filter {
      key    = "PRIORITY"
      values = ["Required", "Important"]
    }
  }

  tags = {
    Name        = "ubuntu-critical-security-baseline"
    Environment = var.environment
    patch_baseline = "yes"
  }
}
resource "aws_ssm_default_patch_baseline" "ubuntu_linux_default" {
  baseline_id      = aws_ssm_patch_baseline.ubuntu_baseline.id
  operating_system = "UBUNTU"
}

# # Patch Baseline for Windows (if needed)
# resource "aws_ssm_patch_baseline" "windows_baseline" {
#   count            = var.enable_windows_patching ? 1 : 0
#   name             = "windows-critical-security-baseline"
#   description      = "Patch baseline for Windows servers - Critical and Security updates"
#   operating_system = "WINDOWS"

#   approval_rule {
#     approve_after_days = 0
#     compliance_level   = "CRITICAL"

#     patch_filter {
#       key    = "CLASSIFICATION"
#       values = ["SecurityUpdates", "CriticalUpdates"]
#     }

#     patch_filter {
#       key    = "MSRC_SEVERITY"
#       values = ["Critical", "Important"]
#     }
#   }

#   tags = {
#     Name        = "windows-critical-security-baseline"
#     Environment = var.environment
#   }
# }

#Patch Group - Associates baseline with tagged instances
resource "aws_ssm_patch_group" "patch_group" {
  baseline_id = aws_ssm_patch_baseline.alma_linux_baseline.id
  patch_group = "production-servers" # Match this with EC2 instance tag
}

#Maintenance Window - Schedule for patching
resource "aws_ssm_maintenance_window" "patching_window" {
  name              = "patching-maintenance-window"
  description       = "Maintenance window for automated patching"
  schedule          = "cron(15 10 16 1 ? 2026)"  # Jan 16, 2026 at 10:15 UTC (15:45 IST)
  duration          = 3                      # 3 hours
  cutoff            = 1                      # Stop 1 hour before end
  allow_unassociated_targets = false

  tags = {
    Name        = "patching-maintenance-window"
    Environment = var.environment
  }
}

#Maintenance Window Target - Which instances to patch
resource "aws_ssm_maintenance_window_target" "patching_target" {
  window_id     = aws_ssm_maintenance_window.patching_window.id
  name          = "patching-targets"
  description   = "Instances to be patched"
  resource_type = "INSTANCE"

  targets {
    key    = "tag:wm-AutoStartStop"
    values = ["yes"] # EC2 instances must have this tag
  }
}

#Maintenance Window Task - Execute patching
resource "aws_ssm_maintenance_window_task" "patch_task" {
  window_id        = aws_ssm_maintenance_window.patching_window.id
  task_type        = "RUN_COMMAND"
  task_arn         = "AWS-RunPatchBaseline"
  priority         = 1
  service_role_arn = aws_iam_role.ssm_maintenance_window_role.arn
  max_concurrency  = "50%"  # Patch 50% of instances at a time
  max_errors       = "25%"  # Stop if 25% fail

  targets {
    key    = "WindowTargetIds"
    values = [aws_ssm_maintenance_window_target.patching_target.id]
  }

  task_invocation_parameters {
    run_command_parameters {
      parameter {
        name   = "Operation"
        values = ["Install"]
      }
      parameter {
        name   = "RebootOption"
        values = ["RebootIfNeeded"] # Options: RebootIfNeeded, NoReboot
      }
    }
  }
}

# IAM Role for Maintenance Window
resource "aws_iam_role" "ssm_maintenance_window_role" {
  name = "ssm-maintenance-window-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ssm.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ssm_maintenance_window_policy" {
  role       = aws_iam_role.ssm_maintenance_window_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonSSMMaintenanceWindowRole"
}

# # SNS Topic for Patch Notifications (Optional)
# resource "aws_sns_topic" "patch_notifications" {
#   count = var.enable_patch_notifications ? 1 : 0
#   name  = "patch-manager-notifications"
# }

# resource "aws_sns_topic_subscription" "patch_email" {
#   count     = var.enable_patch_notifications ? 1 : 0
#   topic_arn = aws_sns_topic.patch_notifications[0].arn
#   protocol  = "email"
#   endpoint  = var.notification_email
# }
