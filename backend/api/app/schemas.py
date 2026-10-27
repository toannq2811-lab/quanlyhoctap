"""JSON shapes. Field names match what the Flutter apps already use."""
from datetime import date, datetime, timezone

from pydantic import BaseModel, Field

from .models import User


def iso(dt: datetime | None) -> str | None:
    """Naive UTC from the database -> ISO 8601 with a Z."""
    if dt is None:
        return None
    return dt.replace(tzinfo=timezone.utc).isoformat().replace('+00:00', 'Z')


def to_utc(dt: datetime) -> datetime:
    if dt.tzinfo is None:
        return dt
    return dt.astimezone(timezone.utc).replace(tzinfo=None)


def profile_json(u: User) -> dict:
    return {
        'id': u.id,
        'username': u.username,
        'name': u.name,
        'birthday': u.birthday.isoformat() if u.birthday else None,
        # Changes whenever the photo changes, so clients know to re-download it.
        'avatar_path': f'{u.id}/{u.avatar_version}' if u.avatar_type else None,
        'role': u.role,
        'last_seen': iso(u.last_seen),
        'created_at': iso(u.created_at),
    }


class Credentials(BaseModel):
    username: str
    password: str


class ProfileUpdate(BaseModel):
    name: str | None = None
    birthday: date | None = None


class QuestionIn(BaseModel):
    id: str = Field(max_length=80)
    section_index: int
    section_title: str = Field(max_length=300)
    position: int
    number: int
    text: str
    options: list[str]
    answer: int | None = None
    explanation: str | None = None


class DeckIn(BaseModel):
    id: str = Field(max_length=64)
    name: str = Field(max_length=200)
    position: int = 0
    questions: list[QuestionIn] = []


class DeckUpdate(BaseModel):
    name: str = Field(max_length=200)


class QuestionUpdate(BaseModel):
    text: str
    options: list[str]
    answer: int | None = None
    explanation: str | None = None


class WordIn(BaseModel):
    id: str = Field(max_length=80)
    position: int
    hanzi: str = Field(max_length=64)
    pinyin: str = ''
    meaning: str = ''


class VocabListIn(BaseModel):
    id: str = Field(max_length=64)
    name: str = Field(max_length=200)
    position: int = 0
    words: list[WordIn] = []


class WordUpdate(BaseModel):
    pinyin: str
    meaning: str


class ResultIn(BaseModel):
    question_id: str
    correct: bool
    updated_at: datetime


class QuestionIds(BaseModel):
    question_ids: list[str]


class AttemptIn(BaseModel):
    deck_id: str | None = None
    at: datetime
    total: int
    right_count: int
    wrong_count: int
    seconds: int


class ActivityIn(BaseModel):
    day: date
    n: int = Field(ge=1, le=10000)


class VocabProgressIn(BaseModel):
    word_id: str = Field(max_length=80)
    known: bool
    correct: int
    wrong: int
    updated_at: datetime


class NewUser(BaseModel):
    username: str
    password: str
    name: str | None = None


class AdminUserUpdate(BaseModel):
    name: str | None = None
    birthday: date | None = None
    role: str | None = None
