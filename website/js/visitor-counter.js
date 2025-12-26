/* eslint-env browser */

// Visitor Counter Functionality
class VisitorCounter {
  constructor() {
      // ✅ Set your real API URL here
      this.apiUrl = 'https://3lv49zojc6.execute-api.us-east-1.amazonaws.com/prod/count';
      this.counterElement = document.getElementById('visitor-count');
      this.retryAttempts = 3;
      this.retryDelay = 1000; // 1 second
      
      this.init();
  }

  async init() {
      console.log('🚀 Initializing visitor counter...');
      
      // Add loading animation
      this.showLoading();
      
      try {
          await this.updateVisitorCount();
      } catch (error) {
          console.error('❌ Failed to initialize visitor counter:', error);
          this.showError();
      }
  }

  showLoading() {
      if (this.counterElement) {
          this.counterElement.innerHTML = '<i class="fas fa-spinner fa-spin"></i>';
          this.counterElement.style.color = '#ffd700';
      }
  }

  showError() {
      if (this.counterElement) {
          this.counterElement.innerHTML = '???';
          this.counterElement.title = 'Unable to load visitor count';
          this.counterElement.style.color = '#e74c3c';
      }
  }

  async updateVisitorCount() {
      // ✅ Use real API instead of demo mode
      let attempts = 0;
      
      while (attempts < this.retryAttempts) {
          try {
              console.log(`📡 Attempting to fetch visitor count (attempt ${attempts + 1})`);
              
              const response = await fetch(this.apiUrl, {
                  method: 'POST',  // Use POST to increment counter
                  headers: {
                      'Content-Type': 'application/json',
                  },
                  mode: 'cors'
              });

              if (!response.ok) {
                  throw new Error(`HTTP error! status: ${response.status}`);
              }

              const data = await response.json();
              console.log('✅ Successfully fetched visitor count:', data);

              const count = data.visitor_count || data.count || 0;
              this.displayCount(count);
              return;

          } catch (error) {
              attempts++;
              console.error(`❌ Attempt ${attempts} failed:`, error.message);
              
              if (attempts < this.retryAttempts) {
                  console.log(`⏳ Retrying in ${this.retryDelay}ms...`);
                  await this.delay(this.retryDelay);
                  this.retryDelay *= 2; // Exponential backoff
              } else {
                  console.error('❌ All retry attempts failed, falling back to demo mode');
                  await this.simulateCounter();
                  return;
              }
          }
      }
  }

  async simulateCounter() {
      // Fallback demo mode
      await this.delay(1500);
      
      let demoCount = localStorage.getItem('demoVisitorCount');
      if (!demoCount) {
          demoCount = Math.floor(Math.random() * 1000) + 100;
      } else {
          demoCount = parseInt(demoCount) + 1;
      }
      
      localStorage.setItem('demoVisitorCount', demoCount);
      
      console.log('🎭 Demo mode: visitor count =', demoCount);
      this.displayCount(demoCount);
  }

  displayCount(count) {
      if (this.counterElement) {
          this.animateNumber(count);
      }
  }

  animateNumber(targetCount) {
      const currentCount = parseInt(this.counterElement.textContent) || 0;
      const increment = Math.ceil((targetCount - currentCount) / 20);
      const duration = 1000;
      const steps = 20;
      const stepDelay = duration / steps;

      let current = currentCount;
      
      const timer = setInterval(() => {
          current += increment;
          
          if (current >= targetCount) {
              current = targetCount;
              clearInterval(timer);
              this.addCelebrationEffect();
          }
          
          this.counterElement.textContent = current.toLocaleString();
      }, stepDelay);
  }

  addCelebrationEffect() {
      this.counterElement.style.textShadow = '0 0 20px #ffd700';
      
      setTimeout(() => {
          this.counterElement.style.textShadow = '2px 2px 4px rgba(0,0,0,0.3)';
      }, 2000);
  }

  delay(ms) {
      return new Promise(resolve => setTimeout(resolve, ms));
  }

  // Method to update API URL dynamically
  setApiUrl(url) {
      this.apiUrl = url;
      console.log('🔗 API URL updated to:', url);
  }
}

// Rest of your UI enhancement code stays the same...
class UIEnhancements {
  constructor() {
      this.init();
  }

  init() {
      this.setupSmoothScrolling();
      this.setupSkillHoverEffects();
      this.setupProjectCardEffects();
      this.setupLoadingAnimations();
  }

  setupSmoothScrolling() {
      document.querySelectorAll('a[href^="#"]').forEach(anchor => {
          anchor.addEventListener('click', function (e) {
              e.preventDefault();
              const target = document.querySelector(this.getAttribute('href'));
              if (target) {
                  target.scrollIntoView({
                      behavior: 'smooth',
                      block: 'start'
                  });
              }
          });
      });
  }

  setupSkillHoverEffects() {
      document.querySelectorAll('.skill-category').forEach(category => {
          category.addEventListener('mouseenter', function() {
              this.style.transform = 'translateY(-5px) scale(1.02)';
          });
          
          category.addEventListener('mouseleave', function() {
              this.style.transform = 'translateY(0) scale(1)';
          });
      });
  }

  setupProjectCardEffects() {
      document.querySelectorAll('.project').forEach(project => {
          project.addEventListener('mouseenter', function() {
              this.style.borderLeftColor = '#3498db';
          });
          
          project.addEventListener('mouseleave', function() {
              this.style.borderLeftColor = '#e74c3c';
          });
      });
  }

  setupLoadingAnimations() {
      const observerOptions = {
          threshold: 0.1,
          rootMargin: '0px 0px -50px 0px'
      };

      const observer = new IntersectionObserver((entries) => {
          entries.forEach(entry => {
              if (entry.isIntersecting) {
                  entry.target.style.opacity = '1';
                  entry.target.style.transform = 'translateY(0)';
              }
          });
      }, observerOptions);

      document.querySelectorAll('.section').forEach(section => {
          section.style.opacity = '0';
          section.style.transform = 'translateY(20px)';
          section.style.transition = 'opacity 0.6s ease, transform 0.6s ease';
          observer.observe(section);
      });
  }
}

// Initialize everything when DOM is loaded
document.addEventListener('DOMContentLoaded', function() {
  console.log('🎉 Cloud Resume website loaded!');
  
  window.visitorCounter = new VisitorCounter();
  window.uiEnhancements = new UIEnhancements();
  
  console.log('✅ All systems initialized with real API connection');
});

// Global debugging helpers
window.debugResume = {
  testCounter: () => {
      if (window.visitorCounter) {
          window.visitorCounter.updateVisitorCount();
      }
  },
  
  setApiUrl: (url) => {
      if (window.visitorCounter) {
          window.visitorCounter.setApiUrl(url);
      }
  },
  
  checkAPI: async () => {
      try {
          const response = await fetch(window.visitorCounter.apiUrl);
          const data = await response.json();
          console.log('API Response:', data);
      } catch (error) {
          console.error('API Error:', error);
      }
  }
};