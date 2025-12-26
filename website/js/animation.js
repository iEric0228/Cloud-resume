class AnimationController {
  constructor() {
    this.init();
  }

  init() {
    this.addScrollAnimations();
    this.addLoadingScreen();
    this.addParticleEffect();
    this.addTypingEffect();
  }

  // Scroll-triggered animations
  addScrollAnimations() {
    const observer = new IntersectionObserver((entries) => {
      entries.forEach(entry => {
        if (entry.isIntersecting) {
          entry.target.classList.add('visible');
        }
      });
    }, { threshold: 0.1 });

    // Add fade-in-up class to sections
    document.querySelectorAll('.section').forEach((section, index) => {
      section.classList.add('fade-in-up');
      section.style.animationDelay = `${index * 0.2}s`;
      observer.observe(section);
    });
  }

  // Loading screen
  addLoadingScreen() {
    const loading = document.createElement('div');
    loading.className = 'loading';
    loading.innerHTML = '<div class="loading-spinner"></div>';
    document.body.appendChild(loading);

    window.addEventListener('load', () => {
      setTimeout(() => {
        loading.style.opacity = '0';
        setTimeout(() => loading.remove(), 500);
      }, 1000);
    });
  }

  // Particle cursor effect
  addParticleEffect() {
    const particles = [];
    const colors = ['#667eea', '#764ba2', '#f093fb', '#f5576c'];

    document.addEventListener('mousemove', (e) => {
      if (Math.random() < 0.1) {
        const particle = document.createElement('div');
        particle.style.cssText = `
                    position: fixed;
                    width: 4px;
                    height: 4px;
                    background: ${colors[Math.floor(Math.random() * colors.length)]};
                    border-radius: 50%;
                    pointer-events: none;
                    z-index: 9999;
                    left: ${e.clientX}px;
                    top: ${e.clientY}px;
                    animation: particleFade 1s ease-out forwards;
                `;
                
        document.body.appendChild(particle);
        setTimeout(() => particle.remove(), 1000);
      }
    });

    // Add CSS for particle animation
    const style = document.createElement('style');
    style.textContent = `
            @keyframes particleFade {
                to {
                    transform: translateY(-20px);
                    opacity: 0;
                }
            }
        `;
    document.head.appendChild(style);
  }

  // Typing effect for tagline
  addTypingEffect() {
    const tagline = document.querySelector('.tagline');
    if (tagline) {
      const text = tagline.textContent;
      tagline.textContent = '';
      tagline.style.borderRight = '2px solid #bdc3c7';

      let index = 0;
      const typeText = () => {
        if (index < text.length) {
          tagline.textContent += text.charAt(index);
          index++;
          setTimeout(typeText, 100);
        } else {
          setTimeout(() => {
            tagline.style.borderRight = 'none';
          }, 1000);
        }
      };

      setTimeout(typeText, 1500);
    }
  }
}

// Initialize animations when DOM loads
document.addEventListener('DOMContentLoaded', () => {
  new AnimationController();
});