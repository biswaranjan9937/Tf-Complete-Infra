const { defineConfig } = require("@playwright/test");

module.exports = defineConfig({
  testDir: "./tests",
  timeout: 300000,
  expect: {
    timeout: 15000
  },
  fullyParallel: false,
  forbidOnly: !!process.env.CI,
  retries: 0,
  reporter: [["list"]],
  use: {
    browserName: "chromium",
    headless: true,
    actionTimeout: 20000,
    navigationTimeout: 60000,
    ignoreHTTPSErrors: true,
    screenshot: "off",
    trace: "retain-on-failure",
    viewport: {
      width: 1600,
      height: 1200
    }
  }
});
