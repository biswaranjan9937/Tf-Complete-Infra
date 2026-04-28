const { STSClient, GetCallerIdentityCommand, GetSessionTokenCommand } = require("@aws-sdk/client-sts");
const fs = require("fs");
const path = require("path");
const os = require("os");

const federationEndpoint = "https://signin.aws.amazon.com/federation";
const region = "ap-south-1";

async function test() {
  // Step 1: Read creds from default profile
  const credsFile = path.join(os.homedir(), ".aws", "credentials");
  const content = fs.readFileSync(credsFile, "utf8");
  const match = content.match(/\[default\]([^\[]*)/);
  const section = match[1];
  const accessKeyId = section.match(/aws_access_key_id\s*=\s*(\S+)/)[1];
  const secretAccessKey = section.match(/aws_secret_access_key\s*=\s*(\S+)/)[1];
  console.log(`1. Creds: ${accessKeyId.slice(0, 10)}...`);

  // Step 2: Verify identity
  const client = new STSClient({ region, credentials: { accessKeyId, secretAccessKey } });
  const id = await client.send(new GetCallerIdentityCommand({}));
  console.log(`2. Identity: ${id.Arn}`);

  // Step 3: GetSessionToken
  const sts = await client.send(new GetSessionTokenCommand({ DurationSeconds: 3600 }));
  console.log(`3. Temp creds obtained: ${sts.Credentials.AccessKeyId.slice(0, 10)}...`);

  // Step 4: Get signin token
  const sessionJson = JSON.stringify({
    sessionId: sts.Credentials.AccessKeyId,
    sessionKey: sts.Credentials.SecretAccessKey,
    sessionToken: sts.Credentials.SessionToken
  });

  const signinResp = await fetch(`${federationEndpoint}?${new URLSearchParams({
    Action: "getSigninToken",
    SessionDuration: "3600",
    Session: sessionJson
  })}`);
  const signinBody = await signinResp.json();
  console.log(`4. SigninToken HTTP: ${signinResp.status}, hasToken: ${!!signinBody.SigninToken}`);

  if (!signinBody.SigninToken) {
    console.log("   ERROR:", JSON.stringify(signinBody));
    return;
  }

  // Step 5: Build login URL and test redirect
  const destination = `https://${region}.console.aws.amazon.com/console/home?region=${region}`;
  const loginUrl = `${federationEndpoint}?${new URLSearchParams({
    Action: "login",
    Issuer: "RunbookGenerator",
    Destination: destination,
    SigninToken: signinBody.SigninToken
  })}`;

  console.log(`5. Login URL length: ${loginUrl.length}`);

  const resp = await fetch(loginUrl, { redirect: "manual" });
  console.log(`6. Login response: HTTP ${resp.status}`);
  console.log(`7. Location: ${resp.headers.get("location") || "none"}`);
  console.log(`8. Set-Cookie: ${resp.headers.get("set-cookie") ? "YES" : "NO"}`);

  // Also try following the redirect
  const resp2 = await fetch(loginUrl, { redirect: "follow" });
  console.log(`9. Final URL after redirects: ${resp2.url}`);
  const body = await resp2.text();
  const isLoginPage = body.includes("Sign in") || body.includes("Email address") || body.includes("IAM user");
  console.log(`10. Landed on login page: ${isLoginPage}`);
  if (isLoginPage) {
    console.log("    FEDERATION IS NOT WORKING - redirecting to login page");
  } else {
    console.log("    ✓ Federation working - landed on console");
  }
}

test().catch(console.error);
