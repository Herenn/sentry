#!/usr/bin/env python3
"""
Check policy exceptions and filter violations
"""

import json
import sys
import yaml
from datetime import datetime
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

def load_policy_config(file_path: str) -> Dict[str, Any]:
    """Load policy configuration"""
    try:
        with open(file_path, 'r') as f:
            return yaml.safe_load(f)
    except (FileNotFoundError, yaml.YAMLError) as e:
        print(f"Error loading policy config: {e}")
        return {}

def is_exception_valid(exception: Dict[str, Any]) -> bool:
    """Check if an exception is still valid (not expired)"""
    expires_at = exception.get('expires_at')
    if not expires_at:
        return True  # No expiration date
    
    try:
        expiry_date = datetime.fromisoformat(expires_at)
        return datetime.now() < expiry_date
    except ValueError:
        print(f"Invalid expiration date format: {expires_at}")
        return False

def should_ignore_violation(violation: Dict, exceptions: List[Dict]) -> bool:
    """Check if a violation should be ignored due to exceptions"""
    rule = violation.get('metadata', {}).get('rule')
    address = violation.get('metadata', {}).get('address', '')
    
    for exception in exceptions:
        if not is_exception_valid(exception):
            continue
        
        # Check if this rule is excepted
        if rule in exception.get('rules', []):
            # Check if address matches (if specified)
            excepted_id = exception.get('id', '')
            if not excepted_id or excepted_id in address:
                return True
    
    return False

def filter_violations(results: List[Dict], policy_config: Dict[str, Any]) -> List[Dict]:
    """Filter violations based on exceptions"""
    exceptions = policy_config.get('exceptions', [])
    filtered_results = []
    
    for result in results:
        if 'failures' not in result:
            filtered_results.append(result)
            continue
        
        filtered_failures = []
        for failure in result['failures']:
            if not should_ignore_violation(failure, exceptions):
                filtered_failures.append(failure)
        
        if filtered_failures:
            filtered_result = result.copy()
            filtered_result['failures'] = filtered_failures
            filtered_results.append(filtered_result)
    
    return filtered_results

def check_blocking_violations(results: List[Dict], policy_config: Dict[str, Any]) -> bool:
    """Check if there are any blocking violations"""
    fail_on = policy_config.get('fail_on', ['high', 'critical'])
    
    for result in results:
        if 'failures' in result:
            for failure in result['failures']:
                severity = failure.get('metadata', {}).get('severity', 'unknown')
                if severity in fail_on:
                    return True
    
    return False

def main():
    """Main function"""
    if len(sys.argv) != 3:
        print("Usage: python3 check_exceptions.py <conftest_results.json> <policy_config.yaml>")
        sys.exit(1)
    
    results_file = sys.argv[1]
    config_file = sys.argv[2]
    
    # Load files
    results = load_conftest_results(results_file)
    policy_config = load_policy_config(config_file)
    
    # Filter violations
    filtered_results = filter_violations(results, policy_config)
    
    # Check for blocking violations
    has_blocking = check_blocking_violations(filtered_results, policy_config)
    
    if has_blocking:
        print("❌ Policy check failed: blocking violations found after applying exceptions")
        
        # Print remaining violations
        for result in filtered_results:
            if 'failures' in result:
                for failure in result['failures']:
                    severity = failure.get('metadata', {}).get('severity', 'unknown')
                    rule = failure.get('metadata', {}).get('rule', 'unknown')
                    message = failure.get('msg', 'No message')
                    print(f"  [{severity}] {rule}: {message}")
        
        sys.exit(1)
    else:
        print("✅ Policy check passed: no blocking violations after applying exceptions")
        sys.exit(0)

if __name__ == '__main__':
    main()
