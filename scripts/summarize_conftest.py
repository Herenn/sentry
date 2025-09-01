#!/usr/bin/env python3
"""
Summarize Conftest output for PR/MR comments
"""

import json
import sys
from collections import defaultdict
from typing import Dict, List, Any

def load_conftest_results(file_path: str) -> List[Dict]:
    """Load conftest results from JSON file"""
    try:
        with open(file_path, 'r') as f:
            results = json.load(f)
        return results if isinstance(results, list) else [results]
    except (FileNotFoundError, json.JSONDecodeError) as e:
        print(f"Error loading conftest results: {e}")
        return []

def group_by_severity(results: List[Dict]) -> Dict[str, List[Dict]]:
    """Group violations by severity"""
    grouped = defaultdict(list)
    
    for result in results:
        if 'failures' in result:
            for failure in result['failures']:
                severity = failure.get('metadata', {}).get('severity', 'unknown')
                grouped[severity].append(failure)
    
    return dict(grouped)

def format_violation(violation: Dict) -> str:
    """Format a single violation for display"""
    rule = violation.get('metadata', {}).get('rule', 'unknown')
    message = violation.get('msg', 'No message provided')
    
    return f"- [{rule}] {message}"

def generate_summary(grouped_violations: Dict[str, List[Dict]]) -> str:
    """Generate markdown summary"""
    if not grouped_violations:
        return """### ✅ Policy Check Summary (OPA/Conftest)

No policy violations found! All checks passed.
"""
    
    # Count violations by severity
    severity_counts = {severity: len(violations) for severity, violations in grouped_violations.items()}
    total_violations = sum(severity_counts.values())
    
    # Sort severities by priority
    severity_order = ['critical', 'high', 'medium', 'low', 'unknown']
    
    summary = "### 🚨 Policy Check Summary (OPA/Conftest)\n\n"
    summary += f"**Total Violations**: {total_violations}\n\n"
    
    # Summary counts
    for severity in severity_order:
        if severity in severity_counts:
            count = severity_counts[severity]
            emoji = {'critical': '🔴', 'high': '🟠', 'medium': '🟡', 'low': '🔵'}.get(severity, '⚪')
            summary += f"- {emoji} **{severity.title()}**: {count}\n"
    
    summary += "\n**Violations**\n\n"
    
    # Detailed violations
    for severity in severity_order:
        if severity in grouped_violations:
            violations = grouped_violations[severity]
            if violations:
                emoji = {'critical': '🔴', 'high': '🟠', 'medium': '🟡', 'low': '🔵'}.get(severity, '⚪')
                summary += f"#### {emoji} {severity.title()} Severity\n\n"
                
                for violation in violations[:10]:  # Limit to first 10
                    summary += format_violation(violation) + "\n"
                
                if len(violations) > 10:
                    summary += f"... and {len(violations) - 10} more\n"
                
                summary += "\n"
    
    # Check if merge should be blocked
    blocking_severities = ['critical', 'high']
    has_blocking_violations = any(severity in grouped_violations for severity in blocking_severities)
    
    if has_blocking_violations:
        summary += "> ⚠️ **Merge is blocked** due to high/critical violations\n\n"
        summary += "Please fix the violations above or add appropriate exceptions to `.inframorph-policy.yaml`\n"
    else:
        summary += "> ✅ **Merge allowed** - no blocking violations found\n"
    
    return summary

def main():
    """Main function"""
    if len(sys.argv) != 2:
        print("Usage: python3 summarize_conftest.py <conftest_results.json>")
        sys.exit(1)
    
    results_file = sys.argv[1]
    results = load_conftest_results(results_file)
    grouped = group_by_severity(results)
    summary = generate_summary(grouped)
    
    print(summary)

if __name__ == '__main__':
    main()
