class VisitorCounter {
  constructor() {
    // ✅ USE PLACEHOLDER - CI/CD will replace this automatically
    this.apiUrl = 'REPLACE_WITH_API_URL';
    this.retryCount = 0;
    this.maxRetries = 3;
    this.retryDelay = 1000; // 1 second
        
    this.init();
  }

  async init() {
    console.log('🔄 Initializing visitor counter...');
    console.log('📡 API URL:', this.apiUrl);
        
    // ✅ Check if URL is still the PLACEHOLDER
    if (this.apiUrl === 'REPLACE_WITH_API_URL') {
      console.warn('⚠️ API URL not replaced - visitor counter disabled');
      this.showError('API URL not configured');
      return;
    }
        
    // ✅ Continue with the visitor counter logic...
    try {
      await this.updateCounter();
    } catch (error) {
      console.error('❌ Failed to initialize visitor counter:', error);
      this.showError('Failed to load');
    }
  }

  async updateCounter() {
    const countElement = document.getElementById('visitor-count');
        
    if (!countElement) {
      console.error('❌ Visitor count element not found');
      return;
    }

    try {
      // Show loading state
      countElement.innerHTML = '<i class="fas fa-spinner fa-spin"></i>';
      countElement.style.color = '#ffd700';
            
      console.log(`📡 Fetching visitor count from: ${this.apiUrl}`);
            
      const response = await fetch(this.apiUrl, {
        method: 'GET',
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        },
        // Add CORS mode
        mode: 'cors'
      });

      console.log(`📊 Response status: ${response.status}`);

      if (!response.ok) {
        throw new Error(`HTTP ${response.status}: ${response.statusText}`);
      }

      const data = await response.json();
      console.log('📈 Response data:', data);
            
      // Handle different response formats
      const count = this.extractCount(data);
            
      if (count === null) {
        throw new Error('Invalid response format - no count found');
      }
            
      // Animate the count
      this.animateCount(countElement, count);
            
      // Reset retry count on success
      this.retryCount = 0;
            
    } catch (error) {
      console.error('💥 Error fetching visitor count:', error);
      this.handleError(countElement, error);
    }
  }

  extractCount(data) {
    // Try different possible response formats
    if (typeof data === 'number') return data;
    if (data.count !== undefined) return parseInt(data.count);
    if (data.visitor_count !== undefined) return parseInt(data.visitor_count);
    if (data.visits !== undefined) return parseInt(data.visits);
    if (data.body && data.body.count !== undefined) return parseInt(data.body.count);
        
    // If response is a string that might be JSON
    if (typeof data === 'string') {
      try {
        const parsed = JSON.parse(data);
        return this.extractCount(parsed);
      } catch (e) {
        console.warn('⚠️ Could not parse string response as JSON');
      }
    }
        
    console.warn('⚠️ Unknown response format:', data);
    return null;
  }

  animateCount(element, finalCount) {
    const duration = 1500; // 1.5 seconds
    const steps = 60;
    const increment = finalCount / steps;
    let current = 0;
    let step = 0;
        
    const timer = setInterval(() => {
      step++;
      current = Math.min(Math.floor(increment * step), finalCount);
            
      element.textContent = current.toLocaleString();
      element.style.color = '#ffd700';
            
      if (step >= steps || current >= finalCount) {
        element.textContent = finalCount.toLocaleString();
        clearInterval(timer);
                
        // Add success styling
        element.style.color = '#ffd700';
        element.style.textShadow = '2px 2px 4px rgba(0,0,0,0.3)';
                
        console.log('✅ Visitor counter updated successfully:', finalCount);
      }
    }, duration / steps);
  }

  handleError(element, error) {
    this.retryCount++;
        
    if (this.retryCount < this.maxRetries) {
      console.log(`🔄 Retrying... (${this.retryCount}/${this.maxRetries})`);
      setTimeout(() => this.updateCounter(), this.retryDelay * this.retryCount);
    } else {
      console.error('💀 Max retries reached. Showing error state.');
      this.showError('Unable to load');
    }
  }

  showError(message = 'Error') {
    const countElement = document.getElementById('visitor-count');
    if (countElement) {
      countElement.innerHTML = `<i class="fas fa-exclamation-triangle"></i> ${message}`;
      countElement.style.color = '#ff6b6b';
    }
  }

  // Method to manually refresh counter (useful for debugging)
  refresh() {
    this.retryCount = 0;
    this.updateCounter();
  }
}

// Initialize when DOM loads
document.addEventListener('DOMContentLoaded', () => {
  // Create global instance for debugging
  window.visitorCounter = new VisitorCounter();
    
  console.log('🎯 Visitor counter initialized. Use window.visitorCounter.refresh() to manually refresh.');
});

// Export for testing
if (typeof module !== 'undefined' && module.exports) {
  module.exports = VisitorCounter;
}