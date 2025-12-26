// Will connect to API Gateway later
async function updateCounter() {
    try {
        const response = await fetch('YOUR_API_GATEWAY_URL');
        const data = await response.json();
        document.getElementById('visitor-count').textContent = data.count;
    } catch (error) {
        console.error('Error fetching count:', error);
        document.getElementById('visitor-count').textContent = 'Error';
    }
}

window.addEventListener('DOMContentLoaded', updateCounter);