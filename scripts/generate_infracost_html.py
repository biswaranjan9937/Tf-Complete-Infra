import json

# -------------------------------
# Load Infracost JSON
# -------------------------------
with open("cost.json") as f:
    data = json.load(f)

project = data["projects"][0]
breakdown = project.get("breakdown", {})

# -------------------------------
# Extract cost summary correctly
# -------------------------------
total_cost = float(breakdown.get("totalMonthlyCost", 0))

# Correct key for usage cost
usage_cost = float(
    breakdown.get("totalUsageBasedCost", 0)
)

# Baseline = total - usage
baseline_cost = total_cost - usage_cost

# -------------------------------
# Extract resources
# -------------------------------
resources = breakdown.get("resources", [])

baseline_resources = []
usage_resources = []

# Keywords to detect usage-based costs
usage_keywords = [
    "request", "data", "transfer", "byte",
    "query", "processed", "scanned",
    "ingested", "retrieved"
]

# -------------------------------
# Categorize resources
# -------------------------------
for r in resources:
    name = r.get("name", "Unknown")
    cost = float(r.get("monthlyCost", 0))

    if any(k in name.lower() for k in usage_keywords):
        usage_resources.append((name, cost))
    else:
        baseline_resources.append((name, cost))

# -------------------------------
# Generate HTML
# -------------------------------
html = f"""
<html>
<head>
<meta charset="UTF-8">
<title>Infracost Cost Report</title>

<style>
body {{
    font-family: Arial, sans-serif;
    background-color: #f9f9f9;
    margin: 20px;
}}

h1 {{
    color: #333;
}}

.summary {{
    background-color: #e9ecef;
    padding: 20px;
    border-radius: 8px;
    margin-bottom: 20px;
}}

.section {{
    margin-top: 30px;
}}

.card {{
    background: white;
    padding: 12px;
    margin-bottom: 10px;
    border-radius: 6px;
}}

.baseline {{
    border-left: 5px solid #007bff;
}}

.usage {{
    border-left: 5px solid #dc3545;
}}

.cost-box {{
    font-size: 18px;
    margin: 8px 0;
}}

</style>
</head>

<body>

<h1>Infracost Cost Report</h1>

<div class="summary">
    <h2>Summary</h2>
    <div class="cost-box"><b>Baseline Cost:</b> ${baseline_cost:.2f}</div>
    <div class="cost-box"><b>Usage Cost:</b> ${usage_cost:.2f}</div>
    <div class="cost-box"><b>Total Cost:</b> ${total_cost:.2f}</div>
</div>

<div class="section">
    <h2>Baseline Costs (Infrastructure)</h2>
"""

# -------------------------------
# Add baseline resources
# -------------------------------
for name, cost in baseline_resources:
    html += f"""
    <div class="card baseline">
        {name} → ${cost:.2f}
    </div>
    """

html += """
</div>

<div class="section">
    <h2>Usage Costs (Traffic & Operations)</h2>
"""

# -------------------------------
# Add usage resources
# -------------------------------
if usage_resources:
    for name, cost in usage_resources:
        html += f"""
        <div class="card usage">
            {name} → ${cost:.2f}
        </div>
        """
else:
    html += "<p>No usage-based costs detected.</p>"

html += """
</div>

</body>
</html>
"""

# -------------------------------
# Write HTML file
# -------------------------------
with open("report.html", "w") as f:
    f.write(html)

print("✅ Custom Infracost HTML report generated: report.html")