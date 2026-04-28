function log(step, level, message, metadata = {}) {
  console.log(JSON.stringify({
    timestamp: new Date().toISOString(),
    step,
    level: String(level || "INFO").toUpperCase(),
    message,
    ...metadata
  }));
}

module.exports = { log };
