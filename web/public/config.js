// config.js — served unhashed so scripts/publish-frontend.sh can inject the
// live API Gateway URL at deploy time without touching the hashed JS bundle.
window.API_URL = 'REPLACE_WITH_API_URL';
