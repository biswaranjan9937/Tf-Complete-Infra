const fs = require("fs");
const path = require("path");
const { test, expect, chromium } = require("@playwright/test");
const { getAwsConsoleLoginUrl, getRegion } = require("../scripts/aws-auth");
const { log } = require("../scripts/logger");

const repoRoot = path.resolve(__dirname, "..");
const consoleUrlsPath = path.join(repoRoot, "console-urls.json");
const screenshotsDir = path.join(repoRoot, "screenshots");

function loadEntries() {
  const parsed = JSON.parse(fs.readFileSync(consoleUrlsPath, "utf8"));
  if (!Array.isArray(parsed.consoleUrls) || parsed.consoleUrls.length === 0) {
    throw new Error("console-urls.json is empty.");
  }
  return parsed.consoleUrls;
}

// Dismiss AWS console popups/tours/modals
async function dismissPopups(page) {
  // The AWS "Service menu" tour has multiple steps with "Next" and finally "Done"
  // Click through all steps or press Escape to close it
  for (let i = 0; i < 10; i++) {
    try {
      // Try Escape key first — closes most modals/popups
      await page.keyboard.press("Escape");
      await page.waitForTimeout(300);

      // Check if popup is still visible
      const visible = await page.locator('text="Service menu"').isVisible({ timeout: 500 }).catch(() => false);
      if (!visible) break;

      // Try clicking Next/Done/Skip buttons
      for (const text of ["Done", "Skip", "Next", "Close", "Dismiss", "Got it"]) {
        const btn = page.locator(`button:has-text("${text}")`).first();
        if (await btn.isVisible({ timeout: 300 }).catch(() => false)) {
          await btn.click({ timeout: 1000 });
          await page.waitForTimeout(300);
          break;
        }
      }
    } catch (_) { break; }
  }
}

// Wait for page to be ready — handles SPA navigation context destruction
async function waitForPageReady(page, timeoutMs = 20000) {
  const start = Date.now();
  while (Date.now() - start < timeoutMs) {
    try {
      await page.waitForLoadState("domcontentloaded", { timeout: 5000 });
      await page.waitForTimeout(2000);
      const text = await page.evaluate(() => document.body ? document.body.innerText.slice(0, 200) : "");
      if (text.length > 10) return;
    } catch (_) {
      await page.waitForTimeout(1000);
    }
  }
}

// Wait for the main content area to have real content (not just spinners)
async function waitForContent(page, timeoutMs = 30000) {
  const start = Date.now();
  while (Date.now() - start < timeoutMs) {
    try {
      // Check if there's a visible loading spinner
      const hasSpinner = await page.evaluate(() => {
        const spinners = document.querySelectorAll(
          '[class*="spinner"], [class*="loading"], [aria-label*="Loading"], [aria-busy="true"]'
        );
        for (const s of spinners) {
          if (s.offsetParent !== null) return true; // visible
        }
        return false;
      });

      if (!hasSpinner) {
        // Double-check: wait a bit more and verify no new spinner appeared
        await page.waitForTimeout(2000);
        const stillSpinner = await page.evaluate(() => {
          const spinners = document.querySelectorAll(
            '[class*="spinner"], [class*="loading"], [aria-label*="Loading"], [aria-busy="true"]'
          );
          for (const s of spinners) {
            if (s.offsetParent !== null) return true;
          }
          return false;
        }).catch(() => false);

        if (!stillSpinner) return;
      }

      await page.waitForTimeout(2000);
    } catch (_) {
      await page.waitForTimeout(1000);
    }
  }
  // Timeout reached — proceed anyway
}

const entries = loadEntries();
let browser, context, page;

test.beforeAll(async () => {
  fs.rmSync(screenshotsDir, { recursive: true, force: true });
  fs.mkdirSync(screenshotsDir, { recursive: true });

  browser = await chromium.launch({ headless: true });
  context = await browser.newContext({
    viewport: { width: 1600, height: 1200 },
    ignoreHTTPSErrors: true
  });
  page = await context.newPage();

  // Login via federation
  const region = getRegion();
  const destination = `https://${region}.console.aws.amazon.com/console/home?region=${region}`;
  const loginUrl = await getAwsConsoleLoginUrl(destination);

  log("screenshot", "INFO", "Navigating to federation login URL");
  // Retry login — federation can be slow or timeout on first attempt
  for (let attempt = 1; attempt <= 3; attempt++) {
    try {
      await page.goto(loginUrl, { waitUntil: "domcontentloaded", timeout: 90000 });
      await waitForPageReady(page);
      break;
    } catch (err) {
      log("screenshot", "WARN", `Login navigation attempt ${attempt} failed: ${err.message}`);
      if (attempt === 3) throw err;
      await page.waitForTimeout(3000);
    }
  }

  // Dismiss the welcome tour popup
  await dismissPopups(page);

  const bodyText = await page.evaluate(() => document.body ? document.body.innerText.slice(0, 500) : "").catch(() => "");
  log("screenshot", "INFO", "Post-login state", { url: page.url(), bodySnippet: bodyText.slice(0, 200) });

  if (bodyText.includes("Email address") || bodyText.includes("IAM user sign in")) {
    await page.screenshot({ path: path.join(screenshotsDir, "_debug-login.png"), fullPage: true });
    throw new Error(`Federation login failed. URL: ${page.url()}`);
  }

  log("screenshot", "INFO", "AWS Console session established");
});

test.afterAll(async () => {
  const shots = fs.existsSync(screenshotsDir)
    ? fs.readdirSync(screenshotsDir).filter((f) => f.endsWith(".png") && !f.startsWith("_debug"))
    : [];
  log("screenshot", "INFO", "Done", { count: shots.length });

  if (page) await page.close().catch(() => {});
  if (context) await context.close().catch(() => {});
  if (browser) await browser.close().catch(() => {});

  if (shots.length === 0) {
    throw new Error("No screenshots generated.");
  }
});

for (const entry of entries) {
  test(`capture ${entry.resource.type}: ${entry.name}`, async () => {
    log("screenshot", "INFO", "Navigating", { name: entry.name, type: entry.resource.type });

    await page.goto(entry.url, { waitUntil: "domcontentloaded", timeout: 60000 });
    await waitForPageReady(page);
    await dismissPopups(page);
    await waitForContent(page);
    await dismissPopups(page);
    // Final settle
    await page.waitForTimeout(2000);
    // One more dismiss in case popup appeared during content load
    await dismissPopups(page);

    // Check if session expired
    if (page.url().includes("signin.aws.amazon.com")) {
      log("screenshot", "WARN", "Session expired, re-authenticating");
      const region = getRegion();
      const loginUrl = await getAwsConsoleLoginUrl(`https://${region}.console.aws.amazon.com/console/home?region=${region}`);
      await page.goto(loginUrl, { waitUntil: "domcontentloaded", timeout: 60000 });
      await waitForPageReady(page);
      await dismissPopups(page);
      await page.goto(entry.url, { waitUntil: "domcontentloaded", timeout: 60000 });
      await waitForPageReady(page);
      await dismissPopups(page);
      await waitForContent(page);
      await page.waitForTimeout(3000);
    }

    const outPath = path.join(screenshotsDir, entry.screenshot);
    await page.screenshot({ path: outPath, fullPage: true, timeout: 20000 });

    log("screenshot", "INFO", "Captured", { name: entry.name, path: outPath });
    expect(fs.existsSync(outPath)).toBeTruthy();
  });
}
