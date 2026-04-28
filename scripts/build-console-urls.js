const fs = require("fs");
const path = require("path");
const { log } = require("./logger");

const repoRoot = path.resolve(__dirname, "..");
const resourcesPath = path.join(repoRoot, "resources.json");
const consoleUrlsPath = path.join(repoRoot, "console-urls.json");

function e(v) { return encodeURIComponent(v); }

// ─── Console URL builders per resource type ───────────────────────────────────
const urlBuilders = {
  // ── Compute ──
  ec2: (r, rg) =>
    `https://${rg}.console.aws.amazon.com/ec2/home?region=${rg}#InstanceDetails:instanceId=${r.id}`,
  launch_template: (r, rg) =>
    `https://${rg}.console.aws.amazon.com/ec2/home?region=${rg}#LaunchTemplates:search=${r.id}`,
  asg: (r, rg) =>
    `https://${rg}.console.aws.amazon.com/ec2/home?region=${rg}#AutoScalingGroupDetails:id=${r.id}`,
  lambda: (r, rg) =>
    `https://${rg}.console.aws.amazon.com/lambda/home?region=${rg}#/functions/${r.id}`,
  lambda_layer: (r, rg) =>
    `https://${rg}.console.aws.amazon.com/lambda/home?region=${rg}#/layers/${r.id}`,

  // ── Containers ──
  ecs_cluster: (r, rg) =>
    `https://${rg}.console.aws.amazon.com/ecs/v2/clusters/${r.id}?region=${rg}`,
  ecs_service: (r, rg) => {
    const cluster = r.cluster.split("/").pop();
    return `https://${rg}.console.aws.amazon.com/ecs/v2/clusters/${e(cluster)}/services/${e(r.service)}?region=${rg}`;
  },
  ecs_task_def: (r, rg) =>
    `https://${rg}.console.aws.amazon.com/ecs/v2/task-definitions/${r.id}?region=${rg}`,
  ecr: (r, rg) =>
    `https://${rg}.console.aws.amazon.com/ecr/repositories/private/${r.id}?region=${rg}`,

  // ── Networking ──
  vpc: (r, rg) =>
    `https://${rg}.console.aws.amazon.com/vpcconsole/home?region=${rg}#VpcDetails:VpcId=${r.id}`,
  subnet: (r, rg) =>
    `https://${rg}.console.aws.amazon.com/vpcconsole/home?region=${rg}#SubnetDetails:subnetId=${r.id}`,
  sg: (r, rg) =>
    `https://${rg}.console.aws.amazon.com/vpcconsole/home?region=${rg}#SecurityGroup:groupId=${r.id}`,
  nat_gateway: (r, rg) =>
    `https://${rg}.console.aws.amazon.com/vpcconsole/home?region=${rg}#NatGatewayDetails:natGatewayId=${r.id}`,
  igw: (r, rg) =>
    `https://${rg}.console.aws.amazon.com/vpcconsole/home?region=${rg}#InternetGateway:internetGatewayId=${r.id}`,
  eip: (r, rg) =>
    `https://${rg}.console.aws.amazon.com/vpcconsole/home?region=${rg}#ElasticIpDetails:AllocationId=${r.id}`,
  route_table: (r, rg) =>
    `https://${rg}.console.aws.amazon.com/vpcconsole/home?region=${rg}#RouteTableDetails:RouteTableId=${r.id}`,
  vpc_peering: (r, rg) =>
    `https://${rg}.console.aws.amazon.com/vpcconsole/home?region=${rg}#PeeringConnectionDetails:VpcPeeringConnectionId=${r.id}`,
  vpc_endpoint: (r, rg) =>
    `https://${rg}.console.aws.amazon.com/vpcconsole/home?region=${rg}#EndpointDetails:vpcEndpointId=${r.id}`,
  eni: (r, rg) =>
    `https://${rg}.console.aws.amazon.com/ec2/home?region=${rg}#NetworkInterface:networkInterfaceId=${r.id}`,
  customer_gateway: (r, rg) =>
    `https://${rg}.console.aws.amazon.com/vpcconsole/home?region=${rg}#CustomerGateways:customerGatewayId=${r.id}`,
  vpn_gateway: (r, rg) =>
    `https://${rg}.console.aws.amazon.com/vpcconsole/home?region=${rg}#VpnGateways:VpnGatewayId=${r.id}`,
  vpn: (r, rg) =>
    `https://${rg}.console.aws.amazon.com/vpcconsole/home?region=${rg}#VpnConnections:vpnConnectionId=${r.id}`,
  transit_gateway: (r, rg) =>
    `https://${rg}.console.aws.amazon.com/vpcconsole/home?region=${rg}#TransitGatewayDetails:transitGatewayId=${r.id}`,

  // ── Load Balancing ──
  alb: (r, rg) => {
    const name = r.arn ? r.arn.split("/").slice(-2, -1)[0] : r.name;
    return `https://${rg}.console.aws.amazon.com/ec2/home?region=${rg}#LoadBalancers:search=${name}`;
  },
  target_group: (r, rg) => {
    const name = r.arn ? r.arn.split("/").slice(-2, -1)[0] : r.name;
    return `https://${rg}.console.aws.amazon.com/ec2/home?region=${rg}#TargetGroups:search=${name}`;
  },

  // ── Storage ──
  s3: (r, rg) =>
    `https://s3.console.aws.amazon.com/s3/buckets/${r.bucket}?region=${rg}&tab=objects`,
  efs: (r, rg) =>
    `https://${rg}.console.aws.amazon.com/efs/home?region=${rg}#/file-systems/${r.id}`,
  fsx: (r, rg) =>
    `https://${rg}.console.aws.amazon.com/fsx/home?region=${rg}#file-system-details/${r.id}`,

  // ── Database ──
  rds: (r, rg) =>
    `https://${rg}.console.aws.amazon.com/rds/home?region=${rg}#database:id=${r.id};is-cluster=false`,
  rds_cluster: (r, rg) =>
    `https://${rg}.console.aws.amazon.com/rds/home?region=${rg}#database:id=${r.id};is-cluster=true`,
  dynamodb: (r, rg) =>
    `https://${rg}.console.aws.amazon.com/dynamodbv2/home?region=${rg}#table?name=${r.id}`,
  elasticache: (r, rg) =>
    `https://${rg}.console.aws.amazon.com/elasticache/home?region=${rg}#/redis/${r.id}`,
  elasticache_cluster: (r, rg) =>
    `https://${rg}.console.aws.amazon.com/elasticache/home?region=${rg}#/redis/${r.id}`,
  redshift: (r, rg) =>
    `https://${rg}.console.aws.amazon.com/redshiftv2/home?region=${rg}#cluster-details?cluster=${r.id}`,

  // ── CDN & DNS ──
  cloudfront: (r) =>
    `https://us-east-1.console.aws.amazon.com/cloudfront/v4/home#/distributions/${r.id}`,
  route53_zone: (r) =>
    `https://us-east-1.console.aws.amazon.com/route53/v2/hostedzones#ListRecordSets/${r.id}`,

  // ── Security & Identity ──
  iam_user: (r) =>
    `https://us-east-1.console.aws.amazon.com/iam/home#/users/details/${r.id}`,
  iam_role: (r) =>
    `https://us-east-1.console.aws.amazon.com/iam/home#/roles/details/${r.id}`,
  iam_policy: (r) =>
    `https://us-east-1.console.aws.amazon.com/iam/home#/policies/details/${e(r.arn)}`,
  iam_group: (r) =>
    `https://us-east-1.console.aws.amazon.com/iam/home#/groups/details/${r.id}`,
  kms: (r, rg) =>
    `https://${rg}.console.aws.amazon.com/kms/home?region=${rg}#/kms/keys/${r.id}`,
  acm: (r, rg) =>
    `https://${rg}.console.aws.amazon.com/acm/home?region=${rg}#/certificates/${e(r.arn)}`,
  secrets_manager: (r, rg) =>
    `https://${rg}.console.aws.amazon.com/secretsmanager/secret?name=${e(r.name)}&region=${rg}`,
  ssm_parameter: (r, rg) =>
    `https://${rg}.console.aws.amazon.com/systems-manager/parameters/${e(r.id)}/description?region=${rg}`,
  waf: (r, rg) =>
    `https://${rg}.console.aws.amazon.com/wafv2/homev2/web-acl/${r.name}/${r.id}/overview?region=${rg}`,

  // ── Monitoring & Logging ──
  cloudtrail: (r, rg) =>
    `https://${rg}.console.aws.amazon.com/cloudtrailv2/home?region=${rg}#/trails/${e(r.arn)}`,
  cw_log_group: (r, rg) =>
    `https://${rg}.console.aws.amazon.com/cloudwatch/home?region=${rg}#logsV2:log-groups/log-group/${e(r.id)}`,
  cw_alarm: (r, rg) =>
    `https://${rg}.console.aws.amazon.com/cloudwatch/home?region=${rg}#alarmsV2:alarm/${r.id}`,
  sns: (r, rg) =>
    `https://${rg}.console.aws.amazon.com/sns/v3/home?region=${rg}#/topic/${e(r.arn)}`,
  sqs: (r, rg) =>
    `https://${rg}.console.aws.amazon.com/sqs/v3/home?region=${rg}#/queues/${e(r.url)}`,

  // ── CI/CD ──
  codepipeline: (r, rg) =>
    `https://${rg}.console.aws.amazon.com/codesuite/codepipeline/pipelines/${r.id}/view?region=${rg}`,
  codebuild: (r, rg) =>
    `https://${rg}.console.aws.amazon.com/codesuite/codebuild/projects/${r.id}?region=${rg}`,
  codecommit: (r, rg) =>
    `https://${rg}.console.aws.amazon.com/codesuite/codecommit/repositories/${r.id}/browse?region=${rg}`,
  codedeploy: (r, rg) =>
    `https://${rg}.console.aws.amazon.com/codesuite/codedeploy/applications/${r.id}?region=${rg}`,

  // ── Management ──
  budget: (r) =>
    `https://us-east-1.console.aws.amazon.com/billing/home#/budgets/details?name=${e(r.id)}`,
  key_pair: (r, rg) =>
    `https://${rg}.console.aws.amazon.com/ec2/home?region=${rg}#KeyPairs:search=${r.id}`,
  dlm: (r, rg) =>
    `https://${rg}.console.aws.amazon.com/ec2/home?region=${rg}#Lifecycle:`,
  ssm_maintenance_window: (r, rg) =>
    `https://${rg}.console.aws.amazon.com/systems-manager/maintenance-windows/${r.id}?region=${rg}`,

  // ── API & Integration ──
  apigw: (r, rg) =>
    `https://${rg}.console.aws.amazon.com/apigateway/main/apis/${r.id}/resources?region=${rg}`,
  apigw_v2: (r, rg) =>
    `https://${rg}.console.aws.amazon.com/apigateway/main/apis/${r.id}?region=${rg}`,
  step_functions: (r, rg) =>
    `https://${rg}.console.aws.amazon.com/states/home?region=${rg}#/statemachines/view/${e(r.arn)}`,
  eventbridge: (r, rg) =>
    `https://${rg}.console.aws.amazon.com/events/home?region=${rg}#/eventbus/default/rules/${r.id}`,

  // ── Analytics & AI ──
  kinesis: (r, rg) =>
    `https://${rg}.console.aws.amazon.com/kinesis/home?region=${rg}#/streams/details/${r.id}`,
  glue_db: (r, rg) =>
    `https://${rg}.console.aws.amazon.com/glue/home?region=${rg}#/v2/data-catalog/databases/view/${r.id}`,
  athena: (r, rg) =>
    `https://${rg}.console.aws.amazon.com/athena/home?region=${rg}#/workgroups/${r.id}`,
  opensearch: (r, rg) =>
    `https://${rg}.console.aws.amazon.com/aos/home?region=${rg}#/opensearch/domains/${r.id}`,
  bedrock: (r, rg) =>
    `https://${rg}.console.aws.amazon.com/bedrock/home?region=${rg}#/custom-models/${r.id}`,

  // ── Transfer ──
  transfer: (r, rg) =>
    `https://${rg}.console.aws.amazon.com/transfer/home?region=${rg}#/servers/${r.id}`,
};

function safeFilename(value) {
  return String(value).replace(/[^a-zA-Z0-9._-]+/g, "-").replace(/^-+|-+$/g, "").toLowerCase();
}

function main() {
  try {
    if (!fs.existsSync(resourcesPath)) {
      throw new Error(`resources.json not found at ${resourcesPath}. Run extract first.`);
    }

    const doc = JSON.parse(fs.readFileSync(resourcesPath, "utf8"));
    if (!doc.region || !Array.isArray(doc.resources) || doc.resources.length === 0) {
      throw new Error("resources.json is empty or invalid.");
    }

    const consoleUrls = [];
    const skipped = [];

    for (const resource of doc.resources) {
      const builder = urlBuilders[resource.type];
      if (!builder) {
        skipped.push(resource.type);
        continue;
      }

      const region = resource.region === "global" ? "us-east-1" : (resource.region || doc.region);
      const url = builder(resource, region);
      consoleUrls.push({
        resource,
        name: resource.name,
        url,
        screenshot: `${resource.type}-${safeFilename(resource.name)}.png`
      });
    }

    if (consoleUrls.length === 0) {
      throw new Error("No console URLs could be generated.");
    }

    const output = { region: doc.region, consoleUrls };
    fs.writeFileSync(consoleUrlsPath, JSON.stringify(output, null, 2) + "\n", "utf8");

    log("map", "INFO", "Built console URLs", {
      total: consoleUrls.length,
      skipped: [...new Set(skipped)],
      types: [...new Set(consoleUrls.map((e) => e.resource.type))].sort()
    });
  } catch (error) {
    log("map", "ERROR", "Failed to build console URLs", { error: error.message });
    process.exit(1);
  }
}

main();
