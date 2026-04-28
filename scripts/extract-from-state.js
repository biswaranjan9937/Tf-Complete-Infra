const fs = require("fs");
const path = require("path");
const { execFileSync } = require("child_process");
const { log } = require("./logger");

const repoRoot = path.resolve(__dirname, "..");
const terraformDir = repoRoot;
const resourcesPath = path.join(repoRoot, "resources.json");

// ─── Resource type → extractor ────────────────────────────────────────────────
// Each extracts identifiers needed to build an AWS Console URL.

const extractors = {
  // ── Compute ──
  aws_instance: (a, v) => ({ type: "ec2", name: v.tags?.Name || a, id: v.id }),
  aws_launch_template: (a, v) => ({ type: "launch_template", name: v.name || a, id: v.id }),
  aws_autoscaling_group: (a, v) => ({ type: "asg", name: v.name || a, id: v.name }),
  aws_lambda_function: (a, v) => ({ type: "lambda", name: v.function_name || a, id: v.function_name }),
  aws_lambda_layer_version: (a, v) => ({ type: "lambda_layer", name: v.layer_name || a, id: v.layer_name }),

  // ── Containers ──
  aws_ecs_cluster: (a, v) => ({ type: "ecs_cluster", name: v.name || a, id: v.name }),
  aws_ecs_service: (a, v) => ({ type: "ecs_service", name: v.name || a, cluster: v.cluster, service: v.name }),
  aws_ecs_task_definition: (a, v) => ({ type: "ecs_task_def", name: v.family || a, id: v.family }),
  aws_ecr_repository: (a, v) => ({ type: "ecr", name: v.name || a, id: v.name }),

  // ── Networking ──
  aws_vpc: (a, v) => ({ type: "vpc", name: v.tags?.Name || a, id: v.id }),
  aws_subnet: (a, v) => ({ type: "subnet", name: v.tags?.Name || a, id: v.id }),
  aws_security_group: (a, v) => ({ type: "sg", name: v.tags?.Name || v.name || a, id: v.id }),
  aws_nat_gateway: (a, v) => ({ type: "nat_gateway", name: v.tags?.Name || a, id: v.id }),
  aws_internet_gateway: (a, v) => ({ type: "igw", name: v.tags?.Name || a, id: v.id }),
  aws_eip: (a, v) => ({ type: "eip", name: v.tags?.Name || a, id: v.allocation_id || v.id }),
  aws_route_table: (a, v) => ({ type: "route_table", name: v.tags?.Name || a, id: v.id }),
  aws_vpc_peering_connection: (a, v) => ({ type: "vpc_peering", name: v.tags?.Name || a, id: v.id }),
  aws_vpc_endpoint: (a, v) => ({ type: "vpc_endpoint", name: v.tags?.Name || a, id: v.id }),
  aws_network_interface: (a, v) => ({ type: "eni", name: v.tags?.Name || a, id: v.id }),
  aws_customer_gateway: (a, v) => ({ type: "customer_gateway", name: v.tags?.Name || a, id: v.id }),
  aws_vpn_gateway: (a, v) => ({ type: "vpn_gateway", name: v.tags?.Name || a, id: v.id }),
  aws_vpn_connection: (a, v) => ({ type: "vpn", name: v.tags?.Name || a, id: v.id }),
  aws_transit_gateway: (a, v) => ({ type: "transit_gateway", name: v.tags?.Name || a, id: v.id }),

  // ── Load Balancing ──
  aws_lb: (a, v) => ({ type: "alb", name: v.tags?.Name || v.name || a, arn: v.arn, dns_name: v.dns_name }),
  aws_alb: (a, v) => ({ type: "alb", name: v.tags?.Name || v.name || a, arn: v.arn, dns_name: v.dns_name }),
  aws_lb_target_group: (a, v) => ({ type: "target_group", name: v.tags?.Name || v.name || a, arn: v.arn }),
  aws_alb_target_group: (a, v) => ({ type: "target_group", name: v.tags?.Name || v.name || a, arn: v.arn }),

  // ── Storage ──
  aws_s3_bucket: (a, v) => ({ type: "s3", name: v.bucket, bucket: v.bucket }),
  aws_efs_file_system: (a, v) => ({ type: "efs", name: v.tags?.Name || a, id: v.id }),
  aws_fsx_lustre_file_system: (a, v) => ({ type: "fsx", name: v.tags?.Name || a, id: v.id }),

  // ── Database ──
  aws_db_instance: (a, v) => ({ type: "rds", name: v.identifier || a, id: v.identifier }),
  aws_rds_cluster: (a, v) => ({ type: "rds_cluster", name: v.cluster_identifier || a, id: v.cluster_identifier }),
  aws_dynamodb_table: (a, v) => ({ type: "dynamodb", name: v.name || a, id: v.name }),
  aws_elasticache_replication_group: (a, v) => ({ type: "elasticache", name: v.replication_group_id || a, id: v.replication_group_id }),
  aws_elasticache_cluster: (a, v) => ({ type: "elasticache_cluster", name: v.cluster_id || a, id: v.cluster_id }),
  aws_redshift_cluster: (a, v) => ({ type: "redshift", name: v.cluster_identifier || a, id: v.cluster_identifier }),

  // ── CDN & DNS ──
  aws_cloudfront_distribution: (a, v) => ({ type: "cloudfront", name: v.comment || a, id: v.id }),
  aws_route53_zone: (a, v) => ({ type: "route53_zone", name: v.name || a, id: v.zone_id, _global: true }),

  // ── Security & Identity ──
  aws_iam_user: (a, v) => ({ type: "iam_user", name: v.name || a, id: v.name, _global: true }),
  aws_iam_role: (a, v) => ({ type: "iam_role", name: v.name || a, id: v.name, _global: true }),
  aws_iam_policy: (a, v) => ({ type: "iam_policy", name: v.name || a, arn: v.arn, _global: true }),
  aws_iam_group: (a, v) => ({ type: "iam_group", name: v.name || a, id: v.name, _global: true }),
  aws_kms_key: (a, v) => ({ type: "kms", name: v.description || a, id: v.key_id }),
  aws_acm_certificate: (a, v) => ({ type: "acm", name: v.domain_name || a, arn: v.arn }),
  aws_secretsmanager_secret: (a, v) => ({ type: "secrets_manager", name: v.name || a, arn: v.arn }),
  aws_ssm_parameter: (a, v) => ({ type: "ssm_parameter", name: v.name || a, id: v.name }),
  aws_wafv2_web_acl: (a, v) => ({ type: "waf", name: v.name || a, id: v.id, arn: v.arn }),

  // ── Monitoring & Logging ──
  aws_cloudtrail: (a, v) => ({ type: "cloudtrail", name: v.name || a, id: v.name, arn: v.arn }),
  aws_cloudwatch_log_group: (a, v) => ({ type: "cw_log_group", name: v.name || a, id: v.name }),
  aws_cloudwatch_metric_alarm: (a, v) => ({ type: "cw_alarm", name: v.alarm_name || a, id: v.alarm_name }),
  aws_sns_topic: (a, v) => ({ type: "sns", name: v.name || a, arn: v.arn }),
  aws_sqs_queue: (a, v) => ({ type: "sqs", name: v.name || a, url: v.url }),

  // ── CI/CD ──
  aws_codepipeline: (a, v) => ({ type: "codepipeline", name: v.name || a, id: v.name }),
  aws_codebuild_project: (a, v) => ({ type: "codebuild", name: v.name || a, id: v.name }),
  aws_codecommit_repository: (a, v) => ({ type: "codecommit", name: v.repository_name || a, id: v.repository_name }),
  aws_codedeploy_app: (a, v) => ({ type: "codedeploy", name: v.name || a, id: v.name }),

  // ── Management ──
  aws_budgets_budget: (a, v) => ({ type: "budget", name: v.name || a, id: v.name, _global: true }),
  aws_key_pair: (a, v) => ({ type: "key_pair", name: v.key_name || a, id: v.key_name }),
  aws_dlm_lifecycle_policy: (a, v) => ({ type: "dlm", name: v.tags?.Name || a, id: v.id }),
  aws_ssm_maintenance_window: (a, v) => ({ type: "ssm_maintenance_window", name: v.name || a, id: v.id }),

  // ── API & Integration ──
  aws_api_gateway_rest_api: (a, v) => ({ type: "apigw", name: v.name || a, id: v.id }),
  aws_apigatewayv2_api: (a, v) => ({ type: "apigw_v2", name: v.name || a, id: v.id }),
  aws_sfn_state_machine: (a, v) => ({ type: "step_functions", name: v.name || a, arn: v.arn }),
  aws_eventbridge_rule: (a, v) => ({ type: "eventbridge", name: v.name || a, id: v.name }),
  aws_cloudwatch_event_rule: (a, v) => ({ type: "eventbridge", name: v.name || a, id: v.name }),

  // ── Analytics & AI ──
  aws_kinesis_stream: (a, v) => ({ type: "kinesis", name: v.name || a, id: v.name }),
  aws_glue_catalog_database: (a, v) => ({ type: "glue_db", name: v.name || a, id: v.name }),
  aws_athena_workgroup: (a, v) => ({ type: "athena", name: v.name || a, id: v.name }),
  aws_opensearch_domain: (a, v) => ({ type: "opensearch", name: v.domain_name || a, id: v.domain_name }),
  aws_elasticsearch_domain: (a, v) => ({ type: "opensearch", name: v.domain_name || a, id: v.domain_name }),
  aws_bedrock_custom_model: (a, v) => ({ type: "bedrock", name: v.custom_model_name || a, id: v.custom_model_name }),

  // ── Transfer & Migration ──
  aws_transfer_server: (a, v) => ({ type: "transfer", name: v.tags?.Name || a, id: v.id }),
};

// ─── Parse terraform show -json ───────────────────────────────────────────────
function getTerraformState() {
  log("extract", "INFO", "Running terraform show -json", { terraformDir });
  const stdout = execFileSync("terraform", ["show", "-json"], {
    cwd: terraformDir,
    encoding: "utf8",
    maxBuffer: 50 * 1024 * 1024,
    stdio: ["ignore", "pipe", "pipe"]
  });
  return JSON.parse(stdout);
}

function detectRegion(state) {
  const resources = state.values?.root_module?.resources || [];
  for (const r of resources) {
    if (r.type === "aws_region" && r.values?.name) return r.values.name;
  }
  return process.env.AWS_REGION || process.env.AWS_DEFAULT_REGION || null;
}

function walkModule(mod, resources, defaultRegion) {
  if (!mod) return;

  for (const r of (mod.resources || [])) {
    const extractor = extractors[r.type];
    if (!extractor || r.mode !== "managed") continue;

    const v = r.values || {};
    const parsed = extractor(r.address, v);
    if (!parsed) continue;

    parsed.address = r.address;
    parsed.region = parsed._global ? "global" : defaultRegion;
    delete parsed._global;
    resources.push(parsed);
  }

  for (const child of (mod.child_modules || [])) {
    walkModule(child, resources, defaultRegion);
  }
}

function dedup(resources) {
  const seen = new Set();
  return resources.filter((r) => {
    const key = `${r.type}:${r.id || r.arn || r.bucket || r.url || r.name}`;
    if (seen.has(key)) return false;
    seen.add(key);
    return true;
  });
}

function main() {
  try {
    if (!fs.existsSync(terraformDir)) {
      throw new Error(`Terraform directory not found: ${terraformDir}`);
    }

    const state = getTerraformState();
    const rootModule = state.values?.root_module;
    if (!rootModule) {
      throw new Error("Terraform state is empty. Run terraform apply first.");
    }

    const defaultRegion = detectRegion(state) || process.env.AWS_REGION || process.env.AWS_DEFAULT_REGION;
    if (!defaultRegion) {
      throw new Error("Cannot determine AWS region from state or environment.");
    }

    const resources = [];
    walkModule(rootModule, resources, defaultRegion);
    const unique = dedup(resources);

    if (unique.length === 0) {
      throw new Error("No supported AWS resources found in Terraform state.");
    }

    const document = { region: defaultRegion, resources: unique };
    fs.writeFileSync(resourcesPath, JSON.stringify(document, null, 2) + "\n", "utf8");

    const types = [...new Set(unique.map((r) => r.type))].sort();
    log("extract", "INFO", "Extracted resources from Terraform state", {
      region: defaultRegion,
      total: unique.length,
      types
    });
  } catch (error) {
    log("extract", "ERROR", "Failed to extract resources", { error: error.message });
    process.exit(1);
  }
}

main();
