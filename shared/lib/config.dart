/// Address of the FastAPI backend (backend/api, deployed on Render).
/// Override when building: flutter build web --dart-define=API_URL=http://127.0.0.1:8000
const apiBaseUrl = String.fromEnvironment(
  'API_URL',
  defaultValue: 'https://studyforyou-api.onrender.com',
);

/// Where the admin website is deployed (its own Netlify site).
const adminSiteUrl = 'https://dienham-admin.netlify.app';
