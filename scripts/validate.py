# scripts/validate.py
#!/usr/bin/env python3
"""
Website validation and testing script
"""
import requests
import boto3
import json
import sys
import os
from urllib.parse import urlparse

class WebsiteValidator:
    def __init__(self, domain):
        self.domain = domain
        self.base_url = f"https://{domain}"
        
    def test_https_redirect(self):
        """Test HTTP to HTTPS redirect"""
        try:
            response = requests.get(f"http://{self.domain}", allow_redirects=False)
            assert response.status_code in [301, 302], f"Expected redirect, got {response.status_code}"
            assert response.headers.get('Location', '').startswith('https'), "Redirect not to HTTPS"
            print("✅ HTTPS redirect working")
            return True
        except Exception as e:
            print(f"❌ HTTPS redirect failed: {e}")
            return False
    
    def test_page_load(self):
        """Test main page loads correctly"""
        try:
            response = requests.get(self.base_url, timeout=10)
            assert response.status_code == 200, f"Page returned {response.status_code}"
            assert len(response.content) > 0, "Empty response"
            print("✅ Main page loads successfully")
            return True
        except Exception as e:
            print(f"❌ Page load failed: {e}")
            return False
    
    def test_security_headers(self):
        """Test security headers are present"""
        try:
            response = requests.get(self.base_url)
            headers = response.headers
            
            required_headers = [
                'x-content-type-options',
                'x-frame-options',
                'x-xss-protection'
            ]
            
            for header in required_headers:
                assert header in headers, f"Missing security header: {header}"
            
            print("✅ Security headers present")
            return True
        except Exception as e:
            print(f"❌ Security headers test failed: {e}")
            return False

    def run_all_tests(self):
        """Run all validation tests"""
        tests = [
            self.test_https_redirect,
            self.test_page_load,
            self.test_security_headers
        ]
        
        results = [test() for test in tests]
        
        if all(results):
            print("\n🎉 All tests passed!")
            return True
        else:
            print(f"\n❌ {len([r for r in results if not r])} tests failed")
            return False

if __name__ == "__main__":
    domain = os.getenv('DOMAIN') or sys.argv[1] if len(sys.argv) > 1 else None
    if not domain:
        print("Usage: python validate.py <domain>")
        sys.exit(1)
    
    validator = WebsiteValidator(domain)
    success = validator.run_all_tests()
    sys.exit(0 if success else 1)