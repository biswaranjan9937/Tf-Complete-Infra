resource "aws_dlm_lifecycle_policy" "ebs_snapshot_policy" {
  description        = "EBS Snapshot Policy"
  execution_role_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/AWSDataLifecycleManagerDefaultRole"
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
  }

  tags = {
    Name          = "Innervex-Technologies-EBS-snapshot-policy"
    Environment   = "PROD"
    Implementedby = "Workmates"
    Managedby     = "Workmates"
    Project       = "Innervex-Technologies"
  }
}

resource "aws_dlm_lifecycle_policy" "ebs_ami_policy" {
  description        = "EBS-backed AMI Policy"
  execution_role_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/AWSDataLifecycleManagerDefaultRole"
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
        interval      = 168
        interval_unit = "HOURS"
        times         = ["18:30"]
      }

      retain_rule {
        count = 7  # Keep for 7 days
      }

      copy_tags = true

    #   variable_tags = {
    #     instance-id = "$(instance-id)"
    #     timestamp   = "$(timestamp)"
    #   }
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