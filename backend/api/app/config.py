"""Settings read from environment variables (set them on Render)."""
import os

# mysql+pymysql://user:pass@host:4000/study?ssl_verify_cert=true  (TiDB Cloud / any MySQL)
# Defaults to a local SQLite file for development and tests.
DATABASE_URL = os.environ.get('DATABASE_URL', 'sqlite:///./dev.db')

# Long random string; tokens signed with it stay valid across restarts.
JWT_SECRET = os.environ.get('JWT_SECRET', 'dev-secret-change-me')
TOKEN_DAYS = int(os.environ.get('TOKEN_DAYS', '60'))

# Comma-separated list of web origins allowed to call the API.
CORS_ORIGINS = [
    o.strip()
    for o in os.environ.get(
        'CORS_ORIGINS',
        'https://dienham.netlify.app,https://dienham-admin.netlify.app,'
        'http://localhost:8765,http://127.0.0.1:8765,http://localhost:8766,http://127.0.0.1:8766',
    ).split(',')
    if o.strip()
]

# Any Netlify site (the apps are hosted there); requests still need a login token.
CORS_ORIGIN_REGEX = os.environ.get('CORS_ORIGIN_REGEX', r'https://[a-z0-9-]+\.netlify\.app')

MAX_AVATAR_BYTES = 2 * 1024 * 1024

# AI explains wrong quiz answers. Set either key (or both: Gemini is tried first,
# Claude takes over if it fails). The feature is off while neither is set.
GEMINI_API_KEY = os.environ.get('GEMINI_API_KEY', '')
GEMINI_MODEL = os.environ.get('GEMINI_MODEL', 'gemini-flash-lite-latest')
ANTHROPIC_API_KEY = os.environ.get('ANTHROPIC_API_KEY', '')
AI_MODEL = os.environ.get('AI_MODEL', 'claude-opus-5-5')
