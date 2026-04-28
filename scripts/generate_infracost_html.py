import json

with open("cost.json") as f:
    data = json.load(f)

project = data["projects"][0]
breakdown = project["breakdown"]

baseline = float(breakdown.get("pastTotalMonthlyCost", 0))
usage = float(breakdown.get("usageCost", 0))
total = float(breakdown.get("totalMonthlyCost", 0))

resources = breakdown.get("resources", [])

baseline_resources = []
usage_resources = []

# 🔥 Separate baseline vs usage
for r in resources:
    name = r.get("name", "")
    cost = float(r.get("monthlyCost", 0))

    # heuristic: usage-related items
    if any(x in name.lower() for x in ["request", "data", "transfer", "bytes", "query"]):
        usage_resources.append((name, cost))
    else:
        baseline_resources.append((name, cost))

html = f"""
<html>
<head>
<title>Infracost Report</title>
<style>
body {{ font-family: Arial; margin: 20px; background:#f9f9f9; }}
h1 {{ color:#333; }}
.summary {{ background:#e9ecef; padding:20px; border-radius:8px; }}
.section {{ margin-top:30px; }}
.card {{ background:white; padding:10px; margin:10px 0; border-radius:6px; }}
.baseline {{ border-left:5px solid #007bff; }}
.usage {{ border-left:5px solid #dc3545; }}
</style>
</head>

<body>

<h1>Infracost Cost Report</h1>

<div class="summary">
<h2>Summary</h2>
<p><b>Baseline Cost:</b> ${baseline}</p>
<p><b>Usage Cost:</b> ${usage}</p>
<p><b>Total Cost:</b> ${total}</p>
</div>

<div class="section">
<h2>Baseline Costs (Infrastructure)</h2>
"""

for name, cost in baseline_resources:
    html += f'<div class="card baseline">{name} → ${cost}</div>'

html += """
</div>

<div class="section">
<h2>Usage Costs (Traffic & Operations)</h2>
"""

for name, cost in usage_resources:
    html += f'<div class="card usage">{name} → ${cost}</div>'

html += """
</div>

</body>
</html>
"""

with open("report.html", "w") as f:
    f.write(html)

print("✅ Custom HTML generated with cost segregation")