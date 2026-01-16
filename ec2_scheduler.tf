# # ========================================
# # EC2 Start/Stop Scheduler using SSM
# # ========================================

# # IAM Role for Maintenance Windows
# resource "aws_iam_role" "ec2_scheduler_role" {
#   name = "ssm-ec2-scheduler-role"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [{
#       Action = "sts:AssumeRole"
#       Effect = "Allow"
#       Principal = {
#         Service = "ssm.amazonaws.com"
#       }
#     }]
#   })

#   tags = {
#     Name        = "ssm-ec2-scheduler-role"
#     Environment = var.environment
#   }
# }

# resource "aws_iam_role_policy_attachment" "ec2_scheduler_policy" {
#   role       = aws_iam_role.ec2_scheduler_role.name
#   policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonSSMMaintenanceWindowRole"
# }

# # Additional policy for EC2 start/stop
# resource "aws_iam_role_policy" "ec2_scheduler_additional" {
#   name = "ec2-start-stop-policy"
#   role = aws_iam_role.ec2_scheduler_role.id

#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect = "Allow"
#         Action = [
#           "ec2:StartInstances",
#           "ec2:StopInstances",
#           "ec2:DescribeInstances",
#           "ec2:DescribeInstanceStatus"
#         ]
#         Resource = "*"
#       }
#     ]
#   })
# }

# # ========================================
# # STOP Instances - Evening
# # ========================================

# resource "aws_ssm_maintenance_window" "stop_instances" {
#   name              = "stop-instances-evening"
#   description       = "Stop EC2 instances in the evening"
#   schedule          = var.stop_schedule
#   duration          = 1
#   cutoff            = 0
#   allow_unassociated_targets = false

#   tags = {
#     Name        = "stop-instances-evening"
#     Environment = var.environment
#   }
# }

# resource "aws_ssm_maintenance_window_target" "stop_target" {
#   window_id     = aws_ssm_maintenance_window.stop_instances.id
#   name          = "instances-to-stop"
#   description   = "EC2 instances to stop"
#   resource_type = "INSTANCE"

#   targets {
#     key    = "tag:AutoSchedule"
#     values = var.auto_schedule_tags
#   }
# }

# resource "aws_ssm_maintenance_window_task" "stop_task" {
#   window_id        = aws_ssm_maintenance_window.stop_instances.id
#   task_type        = "LAMBDA"
#   task_arn         = aws_lambda_function.stop_instances.arn
#   priority         = 1
#   service_role_arn = aws_iam_role.ec2_scheduler_role.arn
#   max_concurrency  = "1"
#   max_errors       = "0"

#   targets {
#     key    = "WindowTargetIds"
#     values = [aws_ssm_maintenance_window_target.stop_target.id]
#   }
# }

# # Lambda function to stop instances
# resource "aws_lambda_function" "stop_instances" {
#   filename         = data.archive_file.stop_lambda.output_path
#   function_name    = "ssm-stop-ec2-instances"
#   role            = aws_iam_role.lambda_scheduler_role.arn
#   handler         = "index.handler"
#   source_code_hash = data.archive_file.stop_lambda.output_base64sha256
#   runtime         = "python3.11"
#   timeout         = 60

#   environment {
#     variables = {
#       TAG_KEY   = "AutoSchedule"
#       TAG_VALUE = join(",", var.auto_schedule_tags)
#     }
#   }
# }

# data "archive_file" "stop_lambda" {
#   type        = "zip"
#   output_path = "${path.module}/lambda_stop.zip"

#   source {
#     content  = <<EOF
# import boto3
# import os

# ec2 = boto3.client('ec2')

# def handler(event, context):
#     tag_key = os.environ['TAG_KEY']
#     tag_values = os.environ['TAG_VALUE'].split(',')
    
#     instances = []
#     for tag_value in tag_values:
#         response = ec2.describe_instances(
#             Filters=[
#                 {'Name': f'tag:{tag_key}', 'Values': [tag_value]},
#                 {'Name': 'instance-state-name', 'Values': ['running']}
#             ]
#         )
#         for reservation in response['Reservations']:
#             for instance in reservation['Instances']:
#                 instances.append(instance['InstanceId'])
    
#     if instances:
#         ec2.stop_instances(InstanceIds=instances)
#         print(f'Stopped instances: {instances}')
#         return {'statusCode': 200, 'body': f'Stopped {len(instances)} instances'}
    
#     return {'statusCode': 200, 'body': 'No instances to stop'}
# EOF
#     filename = "index.py"
#   }
# }

# # IAM role for Lambda
# resource "aws_iam_role" "lambda_scheduler_role" {
#   name = "lambda-ec2-scheduler-role"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [{
#       Action = "sts:AssumeRole"
#       Effect = "Allow"
#       Principal = {
#         Service = "lambda.amazonaws.com"
#       }
#     }]
#   })
# }

# resource "aws_iam_role_policy" "lambda_scheduler_policy" {
#   name = "lambda-ec2-scheduler-policy"
#   role = aws_iam_role.lambda_scheduler_role.id

#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect = "Allow"
#         Action = [
#           "ec2:DescribeInstances",
#           "ec2:StopInstances",
#           "ec2:StartInstances"
#         ]
#         Resource = "*"
#       },
#       {
#         Effect = "Allow"
#         Action = [
#           "logs:CreateLogGroup",
#           "logs:CreateLogStream",
#           "logs:PutLogEvents"
#         ]
#         Resource = "arn:aws:logs:*:*:*"
#       }
#     ]
#   })
# }

# # Lambda permission for SSM
# resource "aws_lambda_permission" "allow_ssm_stop" {
#   statement_id  = "AllowExecutionFromSSM"
#   action        = "lambda:InvokeFunction"
#   function_name = aws_lambda_function.stop_instances.function_name
#   principal     = "ssm.amazonaws.com"
#   source_arn    = aws_ssm_maintenance_window.stop_instances.arn
# }

# # ========================================
# # START Instances - Morning
# # ========================================

# resource "aws_ssm_maintenance_window" "start_instances" {
#   name              = "start-instances-morning"
#   description       = "Start EC2 instances in the morning"
#   schedule          = var.start_schedule
#   duration          = 1
#   cutoff            = 0
#   allow_unassociated_targets = false

#   tags = {
#     Name        = "start-instances-morning"
#     Environment = var.environment
#   }
# }

# resource "aws_ssm_maintenance_window_target" "start_target" {
#   window_id     = aws_ssm_maintenance_window.start_instances.id
#   name          = "instances-to-start"
#   description   = "EC2 instances to start"
#   resource_type = "INSTANCE"

#   targets {
#     key    = "tag:AutoSchedule"
#     values = var.auto_schedule_tags
#   }
# }

# resource "aws_ssm_maintenance_window_task" "start_task" {
#   window_id        = aws_ssm_maintenance_window.start_instances.id
#   task_type        = "AUTOMATION"
#   task_arn         = "AWS-StartEC2Instance"
#   priority         = 1
#   service_role_arn = aws_iam_role.ec2_scheduler_role.arn
#   max_concurrency  = "100%"
#   max_errors       = "0"

#   targets {
#     key    = "WindowTargetIds"
#     values = [aws_ssm_maintenance_window_target.start_target.id]
#   }

#   task_invocation_parameters {
#     automation_parameters {
#       document_version = "$LATEST"

#       parameter {
#         name   = "InstanceId"
#         values = ["{{ TARGET_ID }}"]
#       }
#     }
#   }
# }

# # ========================================
# # Outputs
# # ========================================

# output "stop_maintenance_window_id" {
#   description = "ID of the stop maintenance window"
#   value       = aws_ssm_maintenance_window.stop_instances.id
# }

# output "start_maintenance_window_id" {
#   description = "ID of the start maintenance window"
#   value       = aws_ssm_maintenance_window.start_instances.id
# }

# output "scheduler_role_arn" {
#   description = "ARN of the scheduler IAM role"
#   value       = aws_iam_role.ec2_scheduler_role.arn
# }
