########################################################################
# AWS Rekognition Module
########################################################################

resource "aws_rekognition_collection" "this" {
  count = var.create_collection ? 1 : 0

  collection_id = var.collection_id
  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-${var.collection_id}"
    }
  )
}

resource "aws_rekognition_project" "this" {
  count = var.create_project ? 1 : 0

  project_name = var.project_name
  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-${var.project_name}"
    }
  )
}

resource "aws_rekognition_stream_processor" "this" {
  count = var.create_stream_processor ? 1 : 0

  name = var.stream_processor_name
  role_arn = var.stream_processor_role_arn

  streaming_video_config {
    amazon_kinesis_video_streams_config {
      stream_arn = var.kinesis_video_stream_arn
    }
  }

  face_search_config {
    collection_id = var.create_collection ? aws_rekognition_collection.this[0].collection_id : var.collection_id
    face_match_threshold = var.face_match_threshold
  }

  dynamic "connected_home_config" {
    for_each = var.enable_connected_home ? [1] : []
    content {
      labels = var.connected_home_labels
    }
  }

  notification_channel {
    sns_topic_arn = var.notification_topic_arn
  }

  data_sharing_preference {
    opt_in = var.data_sharing_opt_in
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-${var.stream_processor_name}"
    }
  )
}

resource "aws_rekognition_custom_labels_model" "this" {
  count = var.create_custom_labels_model ? 1 : 0

  project_arn = var.create_project ? aws_rekognition_project.this[0].arn : var.project_arn
  version_name = var.model_version_name
  output_config {
    s3_bucket = var.output_s3_bucket
    s3_key_prefix = var.output_s3_key_prefix
  }

  training_data {
    assets {
      ground_truth_manifest {
        s3_object {
          bucket = var.training_data_bucket
          name = var.training_data_manifest_key
        }
      }
    }
  }

  testing_data {
    auto_create = var.auto_create_testing_data
    dynamic "assets" {
      for_each = var.auto_create_testing_data ? [] : [1]
      content {
        ground_truth_manifest {
          s3_object {
            bucket = var.testing_data_bucket
            name = var.testing_data_manifest_key
          }
        }
      }
    }
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-${var.model_version_name}"
    }
  )
}

resource "aws_rekognition_project_policy" "this" {
  count = var.create_project && var.create_project_policy ? 1 : 0

  project_arn = var.create_project ? aws_rekognition_project.this[0].arn : var.project_arn
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowRekognitionActions"
        Effect = "Allow"
        Principal = {
          AWS = var.project_policy_principal_arns
        }
        Action = var.project_policy_actions
        Resource = var.create_project ? aws_rekognition_project.this[0].arn : var.project_arn
      }
    ]
  })
}
