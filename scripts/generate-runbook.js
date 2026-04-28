const fs = require("fs");
const path = require("path");
const { log } = require("./logger");

const repoRoot = path.resolve(__dirname, "..");
const resourcesPath = path.join(repoRoot, "resources.json");
const consoleUrlsPath = path.join(repoRoot, "console-urls.json");
const screenshotsDir = path.join(repoRoot, "screenshots");
const runbookPath = path.join(repoRoot, "runbook.md");

// Human-readable labels for resource types
const typeLabels = {
  // Compute
  ec2: "EC2 Instances", launch_template: "Launch Templates", asg: "Auto Scaling Groups",
  lambda: "Lambda Functions", lambda_layer: "Lambda Layers",
  // Containers
  ecs_cluster: "ECS Clusters", ecs_service: "ECS Services", ecs_task_def: "ECS Task Definitions",
  ecr: "ECR Repositories",
  // Networking
  vpc: "VPCs", subnet: "Subnets", sg: "Security Groups", nat_gateway: "NAT Gateways",
  igw: "Internet Gateways", eip: "Elastic IPs", route_table: "Route Tables",
  vpc_peering: "VPC Peering Connections", vpc_endpoint: "VPC Endpoints",
  eni: "Network Interfaces", customer_gateway: "Customer Gateways",
  vpn_gateway: "VPN Gateways", vpn: "VPN Connections", transit_gateway: "Transit Gateways",
  // Load Balancing
  alb: "Load Balancers", target_group: "Target Groups",
  // Storage
  s3: "S3 Buckets", efs: "EFS File Systems", fsx: "FSx File Systems",
  // Database
  rds: "RDS Instances", rds_cluster: "RDS Clusters", dynamodb: "DynamoDB Tables",
  elasticache: "ElastiCache", elasticache_cluster: "ElastiCache Clusters",
  redshift: "Redshift Clusters",
  // CDN & DNS
  cloudfront: "CloudFront Distributions", route53_zone: "Route 53 Hosted Zones",
  // Security & Identity
  iam_user: "IAM Users", iam_role: "IAM Roles", iam_policy: "IAM Policies",
  iam_group: "IAM Groups", kms: "KMS Keys", acm: "ACM Certificates",
  secrets_manager: "Secrets Manager", ssm_parameter: "SSM Parameters", waf: "WAF Web ACLs",
  // Monitoring & Logging
  cloudtrail: "CloudTrail", cw_log_group: "CloudWatch Log Groups",
  cw_alarm: "CloudWatch Alarms", sns: "SNS Topics", sqs: "SQS Queues",
  // CI/CD
  codepipeline: "CodePipeline", codebuild: "CodeBuild Projects",
  codecommit: "CodeCommit Repositories", codedeploy: "CodeDeploy Applications",
  // Management
  budget: "Budgets", key_pair: "Key Pairs", dlm: "Lifecycle Policies",
  ssm_maintenance_window: "SSM Maintenance Windows",
  // API & Integration
  apigw: "API Gateway (REST)", apigw_v2: "API Gateway (HTTP/WebSocket)",
  step_functions: "Step Functions", eventbridge: "EventBridge Rules",
  // Analytics & AI
  kinesis: "Kinesis Streams", glue_db: "Glue Databases", athena: "Athena Workgroups",
  opensearch: "OpenSearch Domains", bedrock: "Bedrock Models",
  // Transfer
  transfer: "Transfer Family Servers"
};

function identifier(r) {
  return r.arn || r.id || r.bucket || r.name;
}

function main() {
  try {
    const resources = JSON.parse(fs.readFileSync(resourcesPath, "utf8"));
    const consoleDoc = JSON.parse(fs.readFileSync(consoleUrlsPath, "utf8"));
    const screenshots = fs.existsSync(screenshotsDir)
      ? new Set(fs.readdirSync(screenshotsDir).filter((f) => f.endsWith(".png")))
      : new Set();

    // Group console entries by resource type
    const grouped = {};
    for (const entry of consoleDoc.consoleUrls) {
      const t = entry.resource.type;
      if (!grouped[t]) grouped[t] = [];
      grouped[t].push(entry);
    }

    const lines = [
      "# AWS Infrastructure Runbook",
      "",
      `**Generated:** ${new Date().toISOString()}`,
      "",
      `**Region:** ${resources.region}`,
      "",
      `**Total Resources:** ${consoleDoc.consoleUrls.length}`,
      "",
      "---",
      "",
      "## Table of Contents",
      ""
    ];

    // TOC
    for (const type of Object.keys(grouped)) {
      const label = typeLabels[type] || type;
      const anchor = label.toLowerCase().replace(/[^a-z0-9]+/g, "-");
      lines.push(`- [${label} (${grouped[type].length})](#${anchor})`);
    }
    lines.push("", "---", "");

    // Sections
    for (const [type, entries] of Object.entries(grouped)) {
      const label = typeLabels[type] || type;
      lines.push(`## ${label}`, "");

      for (const entry of entries) {
        lines.push(`### ${entry.name}`, "");
        lines.push(`- **Type:** \`${entry.resource.type}\``);
        lines.push(`- **Identifier:** \`${identifier(entry.resource)}\``);
        if (entry.resource.address) {
          lines.push(`- **Terraform Address:** \`${entry.resource.address}\``);
        }
        lines.push(`- **Console:** [Open in AWS Console](${entry.url})`);
        lines.push("");

        if (screenshots.has(entry.screenshot)) {
          lines.push(`![${entry.name}](screenshots/${entry.screenshot})`, "");
        } else {
          lines.push(`> ⚠️ Screenshot not available: \`${entry.screenshot}\``, "");
        }
      }
    }

    fs.writeFileSync(runbookPath, lines.join("\n").trim() + "\n", "utf8");

    log("runbook", "INFO", "Generated runbook", {
      path: runbookPath,
      resources: consoleDoc.consoleUrls.length,
      screenshots: screenshots.size,
      sections: Object.keys(grouped).length
    });
  } catch (error) {
    log("runbook", "ERROR", "Failed", { error: error.message });
    process.exit(1);
  }
}

main();
