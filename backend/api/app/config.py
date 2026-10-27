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

MAX_AVATAR_BYTES = 2 * 1024 * 1024
