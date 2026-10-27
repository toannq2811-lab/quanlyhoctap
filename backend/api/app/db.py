from sqlalchemy import create_engine, event
from sqlalchemy.orm import DeclarativeBase, sessionmaker

from .config import DATABASE_URL


def make_engine(url: str):
    if url.startswith('sqlite'):
        engine = create_engine(url, connect_args={'check_same_thread': False})

        @event.listens_for(engine, 'connect')
        def _fk_on(dbapi_conn, _):  # SQLite ignores foreign keys unless asked
            dbapi_conn.execute('PRAGMA foreign_keys=ON')

        return engine
    # TLS with a known CA bundle (TiDB Cloud requires it); pool_pre_ping because
    # free MySQL hosts drop idle connections.
    import certifi

    return create_engine(url, pool_pre_ping=True, pool_recycle=280,
                         connect_args={'ssl': {'ca': certifi.where()}})


engine = make_engine(DATABASE_URL)
SessionLocal = sessionmaker(bind=engine, autoflush=False, expire_on_commit=False)


class Base(DeclarativeBase):
    pass


def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
