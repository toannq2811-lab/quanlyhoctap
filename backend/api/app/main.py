"""Study For You API — FastAPI + MySQL.

Run locally:  uvicorn app.main:app --reload --port 8000
"""
from contextlib import asynccontextmanager

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from . import models  # noqa: F401  (registers the tables)
from .config import CORS_ORIGIN_REGEX, CORS_ORIGINS
from .db import Base, engine
from .routers import admin, auth, content, progress


@asynccontextmanager
async def lifespan(_: FastAPI):
    Base.metadata.create_all(engine)  # creates missing tables, never drops data
    yield


app = FastAPI(title='Study For You API', lifespan=lifespan)
app.add_middleware(
    CORSMiddleware,
    allow_origins=CORS_ORIGINS,
    allow_origin_regex=CORS_ORIGIN_REGEX,
    allow_methods=['*'],
    allow_headers=['*'],
)


@app.get('/')
def health():
    """Also used by Render's health check and by the keep-awake ping."""
    return {'ok': True}


for r in (auth.router, content.router, progress.router, admin.router):
    app.include_router(r)
