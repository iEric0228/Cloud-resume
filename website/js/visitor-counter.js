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
        
    // ✅ FIX: Check for placeholder text that is unique
    if (this.apiUrl.includes('REPLACE_WITH') || this.apiUrl === 'REPLACE_WITH_API_URL') {
      console.warn('⚠️ API URL not replaced - visitor counter disabled');
      this.showError('API URL not configured');
      return;
    }
    
    // ✅ ADD: Validate API URL format
    if (!this.apiUrl || !this.apiUrl.startsWith('https://')) {
      console.warn('⚠️ Invalid API URL format:', this.apiUrl);
      this.showError('Invalid API URL');
      return;
    }

    console.log('✅ API URL validated, proceeding with counter initialization');
    
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
      console.log('📡 Fetching visitor count from:', this.apiUrl);
      
      const response = await fetch(this.apiUrl, {
        method: 'GET',
        headers: {
          'Content-Type': 'application/json',
        }
      });

      if (!response.ok) {
        throw new Error(`HTTP ${response.status}: ${response.statusText}`);
      }

      const data = await response.json();
      console.log('📊 API Response:', data);
      
      const count = this.extractCount(data);
      
      if (count === null) {
        throw new Error('Could not extract visitor count from response');
      }

      console.log(`✅ Visitor counter updated successfully: ${count}`);
      
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
    if (typeof data === 'object' && data !== null) {
      if (typeof data.visitor_count === 'number') {
        return data.visitor_count;
      }
      if (typeof data.count === 'number') {
        return data.count;
      }
      if (typeof data.visitors === 'number') {
        return data.visitors;
      }
    }
    return null;
  }

  animateCount(element, targetCount) {
    const duration = 2000; // 2 seconds
    const startTime = Date.now();
    const startCount = 0;

    const animate = () => {
      const elapsed = Date.now() - startTime;
      const progress = Math.min(elapsed / duration, 1);
      
      // Easing function for smooth animation
      const easeOut = 1 - Math.pow(1 - progress, 3);
      const currentCount = Math.floor(startCount + (targetCount - startCount) * easeOut);
      
      element.textContent = currentCount.toLocaleString();
      
      if (progress < 1) {
        requestAnimationFrame(animate);
      } else {
        element.textContent = targetCount.toLocaleString();
        this.applyGoldenStyling(element);
      }
    };

    animate();
  }

  applyGoldenStyling(element) {
    element.style.background = 'linear-gradient(45deg, #FFD700, #FFA500, #FFD700)';
    element.style.backgroundClip = 'text';
    element.style.webkitBackgroundClip = 'text';
    element.style.webkitTextFillColor = 'transparent';
    element.style.animation = 'pulse 2s ease-in-out infinite alternate';
  }

  async handleError(countElement, error) {
    this.retryCount++;
    
    if (this.retryCount <= this.maxRetries) {
      console.log(`🔄 Retry ${this.retryCount}/${this.maxRetries} in ${this.retryDelay}ms...`);
      setTimeout(() => this.updateCounter(), this.retryDelay);
      this.retryDelay *= 1.5; // Exponential backoff
    } else {
      console.error('💥 Max retries exceeded, giving up');
      this.showError('Failed to load');
    }
  }

  showError(message) {
    const countElement = document.getElementById('visitor-count');
    if (countElement) {
      countElement.textContent = message;
      countElement.style.color = '#ff6b6b';
      countElement.style.background = 'none';
      countElement.style.webkitTextFillColor = 'initial';
    }
  }
}

// Initialize when DOM loads
document.addEventListener('DOMContentLoaded', () => {
  console.log('🚀 DOM loaded, initializing visitor counter...');
  new VisitorCounter();
});

// Also initialize if DOM is already loaded
if (document.readyState === 'loading') {
  // Do nothing, DOMContentLoaded will fire
} else {
  // DOM already loaded
  console.log('🚀 DOM already loaded, initializing visitor counter...');
  new VisitorCounter();
}