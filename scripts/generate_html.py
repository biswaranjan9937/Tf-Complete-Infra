import json
from html import escape

# Load JSON
with open("report.json") as f:
    data = json.load(f)

# Handle list vs dict (Checkov sometimes outputs list)
if isinstance(data, list):
    data = data[0]

results = data.get("results", {})

failed = results.get("failed_checks", [])
passed = results.get("passed_checks", [])

# Start HTML
html = f"""
<html>
<head>
<meta charset="UTF-8">
<title>Checkov Report</title>

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
    padding: 20px;
    background: #eaeaea;
    border-radius: 10px;
    margin-bottom: 20px;
}}

.failed {{
    background-color: #ffe6e6;
    border-left: 6px solid #d9534f;
}}

.passed {{
    background-color: #e6ffe6;
    border-left: 6px solid #5cb85c;
}}

.card {{
    border-radius: 8px;
    padding: 15px;
    margin-bottom: 15px;
}}

.code {{
    background: #f4f4f4;
    padding: 10px;
    font-family: monospace;
    white-space: pre-wrap;
    overflow-x: auto;
}}

.section-title {{
    border-bottom: 2px solid #ccc;
    padding-bottom: 5px;
    margin-top: 30px;
}}
</style>

</head>

<body>

<h1>Checkov Scan Report</h1>

<div class="summary">
  <h2>Summary</h2>
  <p><b>Passed:</b> {len(passed)}</p>
  <p><b>Failed:</b> {len(failed)}</p>
  <p><b>Total:</b> {len(passed) + len(failed)}</p>
</div>

<h2 class="section-title" style="color:#d9534f;">Failed Checks</h2>
"""

# -------- FAILED CHECKS --------
for c in failed:
    html += f"""
    <div class="card failed">
        <h3>{escape(str(c.get('check_id')))} - {escape(str(c.get('check_name')))}</h3>
        <p><b>Resource:</b> {escape(str(c.get('resource')))}</p>
        <p><b>File:</b> {escape(str(c.get('file_path')))}</p>
        <p><b>Guideline:</b> <a href="{escape(str(c.get('guideline', '#')))}" target="_blank">View Fix</a></p>

        <div class="code">
"""

    # Code block
    for line in c.get("code_block", []):
        html += escape(line[1])

    html += """
        </div>
    </div>
    """

# -------- PASSED CHECKS --------
html += """
<h2 class="section-title" style="color:#5cb85c;">Passed Checks</h2>
"""

for c in passed:
    html += f"""
    <div class="card passed">
        <h4>{escape(str(c.get('check_id')))} - {escape(str(c.get('check_name')))}</h4>
        <p><b>Resource:</b> {escape(str(c.get('resource')))}</p>
        <p><b>File:</b> {escape(str(c.get('file_path')))}</p>
    </div>
    """

html += """
</body>
</html>
"""

# Write file
with open("report.html", "w", encoding="utf-8") as f:
    f.write(html)

print("✅ HTML report generated: report.html")