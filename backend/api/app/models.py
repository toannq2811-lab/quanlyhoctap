from datetime import date, datetime, timezone

from sqlalchemy import (JSON, Boolean, Date, DateTime, ForeignKey, Index, Integer, LargeBinary,
                        String, Text)
from sqlalchemy.orm import Mapped, mapped_column

from .db import Base


def utcnow() -> datetime:
    return datetime.now(timezone.utc).replace(tzinfo=None)


class User(Base):
    __tablename__ = 'users'

    id: Mapped[str] = mapped_column(String(36), primary_key=True)
    username: Mapped[str] = mapped_column(String(30), unique=True)
    password_hash: Mapped[str] = mapped_column(String(100))
    name: Mapped[str | None] = mapped_column(String(100))
    birthday: Mapped[date | None] = mapped_column(Date)
    role: Mapped[str] = mapped_column(String(10), default='student')
    last_seen: Mapped[datetime | None] = mapped_column(DateTime)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=utcnow)
    # Small square PNG/JPEG; MEDIUMBLOB on MySQL.
    avatar: Mapped[bytes | None] = mapped_column(LargeBinary(16 * 1024 * 1024), deferred=True)
    avatar_type: Mapped[str | None] = mapped_column(String(30))
    avatar_version: Mapped[int] = mapped_column(Integer, default=0)


class Deck(Base):
    __tablename__ = 'decks'

    id: Mapped[str] = mapped_column(String(64), primary_key=True)
    name: Mapped[str] = mapped_column(String(200))
    position: Mapped[int] = mapped_column(Integer, default=0)
    created_by: Mapped[str | None] = mapped_column(ForeignKey('users.id', ondelete='SET NULL'))
    created_at: Mapped[datetime] = mapped_column(DateTime, default=utcnow)


class Question(Base):
    __tablename__ = 'questions'
    __table_args__ = (Index('questions_deck_idx', 'deck_id'),)

    id: Mapped[str] = mapped_column(String(80), primary_key=True)
    deck_id: Mapped[str] = mapped_column(ForeignKey('decks.id', ondelete='CASCADE'))
    section_index: Mapped[int] = mapped_column(Integer)
    section_title: Mapped[str] = mapped_column(String(300))
    position: Mapped[int] = mapped_column(Integer)
    number: Mapped[int] = mapped_column(Integer)
    text: Mapped[str] = mapped_column(Text)
    options: Mapped[list] = mapped_column(JSON)
    answer: Mapped[int | None] = mapped_column(Integer)
    explanation: Mapped[str | None] = mapped_column(Text)


class Result(Base):
    __tablename__ = 'results'

    user_id: Mapped[str] = mapped_column(ForeignKey('users.id', ondelete='CASCADE'), primary_key=True)
    question_id: Mapped[str] = mapped_column(ForeignKey('questions.id', ondelete='CASCADE'), primary_key=True)
    correct: Mapped[bool] = mapped_column(Boolean)
    updated_at: Mapped[datetime] = mapped_column(DateTime, default=utcnow)


class Attempt(Base):
    __tablename__ = 'attempts'
    __table_args__ = (Index('attempts_user_idx', 'user_id', 'at'),)

    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    user_id: Mapped[str] = mapped_column(ForeignKey('users.id', ondelete='CASCADE'))
    deck_id: Mapped[str | None] = mapped_column(ForeignKey('decks.id', ondelete='CASCADE'))
    at: Mapped[datetime] = mapped_column(DateTime, default=utcnow)
    total: Mapped[int] = mapped_column(Integer)
    right_count: Mapped[int] = mapped_column(Integer)
    wrong_count: Mapped[int] = mapped_column(Integer)
    seconds: Mapped[int] = mapped_column(Integer)


class DailyActivity(Base):
    __tablename__ = 'daily_activity'

    user_id: Mapped[str] = mapped_column(ForeignKey('users.id', ondelete='CASCADE'), primary_key=True)
    day: Mapped[date] = mapped_column(Date, primary_key=True)
    count: Mapped[int] = mapped_column(Integer, default=0)


class VocabList(Base):
    __tablename__ = 'vocab_lists'

    id: Mapped[str] = mapped_column(String(64), primary_key=True)
    name: Mapped[str] = mapped_column(String(200))
    position: Mapped[int] = mapped_column(Integer, default=0)
    created_by: Mapped[str | None] = mapped_column(ForeignKey('users.id', ondelete='SET NULL'))
    created_at: Mapped[datetime] = mapped_column(DateTime, default=utcnow)


class VocabWord(Base):
    __tablename__ = 'vocab_words'
    __table_args__ = (Index('vocab_words_list_idx', 'list_id'),)

    id: Mapped[str] = mapped_column(String(80), primary_key=True)
    list_id: Mapped[str] = mapped_column(ForeignKey('vocab_lists.id', ondelete='CASCADE'))
    position: Mapped[int] = mapped_column(Integer)
    hanzi: Mapped[str] = mapped_column(String(64))
    pinyin: Mapped[str] = mapped_column(String(160), default='')
    meaning: Mapped[str] = mapped_column(Text)


class VocabProgress(Base):
    __tablename__ = 'vocab_progress'

    user_id: Mapped[str] = mapped_column(ForeignKey('users.id', ondelete='CASCADE'), primary_key=True)
    # "hsk1-爱" for built-in words, or a vocab_words id.
    word_id: Mapped[str] = mapped_column(String(80), primary_key=True)
    known: Mapped[bool] = mapped_column(Boolean, default=False)
    correct: Mapped[int] = mapped_column(Integer, default=0)
    wrong: Mapped[int] = mapped_column(Integer, default=0)
    updated_at: Mapped[datetime] = mapped_column(DateTime, default=utcnow)
