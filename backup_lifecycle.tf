resource "aws_dlm_lifecycle_policy" "ebs_snapshot_policy" {
  description        = "EBS Snapshot Policy"
  execution_role_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/service-role/AWSDataLifecycleManagerDefaultRole"
  state              = "ENABLED"

  policy_details {
    policy_type = "EBS_SNAPSHOT_MANAGEMENT"

    resource_types   = ["INSTANCE"]
    target_tags = {
      dlcm = "yes"
    }

    schedule {
      name = "Daily EBS Snapshots"

      create_rule {
        interval      = 24
        interval_unit = "HOURS"
        times         = ["18:00"]
      }

      retain_rule {
        count = 7
      }

      copy_tags = true
    }
    parameters {
      no_reboot          = true
    }
  }

  tags = {
    Name          = "Innervex-Technologies-EBS-snapshot-policy"
    Environment   = "PROD"
    Implementedby = "Workmates"
    Managedby     = "Workmates"
    Project       = "Innervex-Technologies"
  }
}

resource "aws_iam_role" "dlm_lifecycle_role" {
  name = "AWSDataLifecycleManagerDefaultRoleForAMIManagement"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "dlm.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "dlm_lifecycle_role_policy" {
  role       = aws_iam_role.dlm_lifecycle_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSDataLifecycleManagerServiceRoleForAMIManagement"
}

resource "aws_dlm_lifecycle_policy" "ebs_ami_policy" {
  description        = "EBS-backed AMI Policy"
  execution_role_arn = aws_iam_role.dlm_lifecycle_role.arn
  state              = "ENABLED"

  policy_details {
    policy_type = "IMAGE_MANAGEMENT"

    resource_types = ["INSTANCE"]
    target_tags = {
      wm_backup = "yes"
    }

    schedule {
      name = "Weekly AMI Backup"

      create_rule {
        cron_expression = "cron(30 18 ? * FRI *)"  # Friday 18:30 UTC
      }

      retain_rule {
        count = 7
      }

      copy_tags = true
    }

    parameters {
      exclude_boot_volume = false
      no_reboot          = true
    }
  }

  tags = {
    Name          = "innervex-technologies-ami-backup-policy"
    Environment   = "PROD"
    Implementedby = "Workmates"
    Managedby     = "Workmates"
    Project       = "Innervex-Technologies"
  }
}