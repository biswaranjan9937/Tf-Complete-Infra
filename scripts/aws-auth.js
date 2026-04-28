const { STSClient, GetCallerIdentityCommand, GetFederationTokenCommand } = require("@aws-sdk/client-sts");
const { log } = require("./logger");
const fs = require("fs");
const path = require("path");
const os = require("os");

const federationEndpoint = "https://signin.aws.amazon.com/federation";

function getRegion() {
  const region = process.env.AWS_REGION || process.env.AWS_DEFAULT_REGION;
  if (!region) {
    throw new Error("AWS region is not set. Define AWS_REGION or AWS_DEFAULT_REGION.");
  }
  return region;
}

let cachedSession = null;

async function getSessionCredentials(region) {
  if (cachedSession) return cachedSession;

  const defaultClient = new STSClient({ region });
  const identity = await defaultClient.send(new GetCallerIdentityCommand({}));
  log("aws-auth", "INFO", "Validated AWS credentials", {
    account: identity.Account,
    arn: identity.Arn,
    region
  });

  const arn = identity.Arn || "";
  const isAssumedRole = arn.includes(":assumed-role/");

  if (isAssumedRole) {
    // GitHub Actions OIDC / assumed role — already has valid federation-compatible creds
    log("aws-auth", "INFO", "Assumed role detected, using existing credentials");
    const creds = await defaultClient.config.credentials();
    cachedSession = {
      sessionId: creds.accessKeyId,
      sessionKey: creds.secretAccessKey,
      sessionToken: creds.sessionToken
    };
    return cachedSession;
  }

  // IAM user — must use GetFederationToken (NOT GetSessionToken)
  log("aws-auth", "INFO", "IAM user detected, calling GetFederationToken");

  // Read long-term keys explicitly to avoid cached session tokens
  let accessKeyId, secretAccessKey;
  const credsFile = path.join(os.homedir(), ".aws", "credentials");
  if (fs.existsSync(credsFile)) {
    const content = fs.readFileSync(credsFile, "utf8");
    const profile = process.env.AWS_PROFILE || "default";
    const match = content.match(new RegExp(`\\[${profile}\\]([^\\[]*)`));
    if (match) {
      const section = match[1];
      const keyMatch = section.match(/aws_access_key_id\s*=\s*(\S+)/);
      const secretMatch = section.match(/aws_secret_access_key\s*=\s*(\S+)/);
      const hasSessionToken = /aws_session_token\s*=/.test(section);
      if (keyMatch && secretMatch && !hasSessionToken) {
        accessKeyId = keyMatch[1];
        secretAccessKey = secretMatch[1];
        log("aws-auth", "INFO", `Read long-term credentials from profile [${profile}]`);
      }
    }
  }

  if (!accessKeyId || !secretAccessKey) {
    accessKeyId = process.env.AWS_ACCESS_KEY_ID;
    secretAccessKey = process.env.AWS_SECRET_ACCESS_KEY;
  }

  if (!accessKeyId || !secretAccessKey) {
    throw new Error("Cannot find long-term IAM credentials for federation.");
  }

  const stsClient = new STSClient({
    region,
    credentials: { accessKeyId, secretAccessKey }
  });

  const resp = await stsClient.send(new GetFederationTokenCommand({
    Name: "runbook-console-session",
    DurationSeconds: 3600,
    Policy: JSON.stringify({
      Version: "2012-10-17",
      Statement: [{ Effect: "Allow", Action: "*", Resource: "*" }]
    })
  }));

  cachedSession = {
    sessionId: resp.Credentials.AccessKeyId,
    sessionKey: resp.Credentials.SecretAccessKey,
    sessionToken: resp.Credentials.SessionToken
  };
  log("aws-auth", "INFO", "Obtained federation token from STS");
  return cachedSession;
}

async function getSigninToken(sessionJson) {
  const params = new URLSearchParams({
    Action: "getSigninToken",
    SessionDuration: "3600",
    Session: JSON.stringify(sessionJson)
  });

  const response = await fetch(`${federationEndpoint}?${params.toString()}`);
  if (!response.ok) {
    const body = await response.text().catch(() => "");
    throw new Error(`Federation getSigninToken returned HTTP ${response.status}: ${body}`);
  }

  const payload = await response.json();
  if (!payload.SigninToken) {
    throw new Error("Federation endpoint did not return a SigninToken.");
  }

  log("aws-auth", "INFO", "Obtained federation SigninToken");
  return payload.SigninToken;
}

async function getAwsConsoleLoginUrl(destination) {
  if (!destination) {
    throw new Error("A destination URL is required.");
  }

  const region = getRegion();
  const session = await getSessionCredentials(region);
  const signinToken = await getSigninToken(session);

  const params = new URLSearchParams({
    Action: "login",
    Issuer: "RunbookGenerator",
    Destination: destination,
    SigninToken: signinToken
  });

  const loginUrl = `${federationEndpoint}?${params.toString()}`;
  log("aws-auth", "INFO", "Built federated login URL", { destination, region });
  return loginUrl;
}

module.exports = { getAwsConsoleLoginUrl, getRegion };
