"""The signed-in user's own progress: answers, sessions, daily activity, vocabulary."""
from datetime import date

from fastapi import APIRouter, Depends
from sqlalchemy import delete, select
from sqlalchemy.orm import Session

from ..db import get_db
from ..models import Attempt, DailyActivity, Deck, Question, Result, User, VocabProgress
from ..schemas import (ActivityIn, AttemptIn, QuestionIds, ResultIn, VocabProgressIn, iso,
                       to_utc)
from ..security import current_user

router = APIRouter(prefix='/me')


def result_json(r: Result) -> dict:
    return {'user_id': r.user_id, 'question_id': r.question_id, 'correct': r.correct,
            'updated_at': iso(r.updated_at)}


def attempt_json(a: Attempt) -> dict:
    return {'user_id': a.user_id, 'deck_id': a.deck_id, 'at': iso(a.at), 'total': a.total,
            'right_count': a.right_count, 'wrong_count': a.wrong_count, 'seconds': a.seconds}


def activity_json(a: DailyActivity) -> dict:
    return {'user_id': a.user_id, 'day': a.day.isoformat(), 'count': a.count}


def vocab_json(v: VocabProgress) -> dict:
    return {'user_id': v.user_id, 'word_id': v.word_id, 'known': v.known, 'correct': v.correct,
            'wrong': v.wrong, 'updated_at': iso(v.updated_at)}


@router.get('/results')
def my_results(user: User = Depends(current_user), db: Session = Depends(get_db)):
    return [result_json(r) for r in db.scalars(select(Result).where(Result.user_id == user.id))]


@router.put('/results')
def save_results(body: list[ResultIn], user: User = Depends(current_user), db: Session = Depends(get_db)):
    """Upsert answers; answers to questions that no longer exist are skipped."""
    ids = {r.question_id for r in body}
    existing = set(db.scalars(select(Question.id).where(Question.id.in_(ids)))) if ids else set()
    for r in body:
        if r.question_id not in existing:
            continue
        row = db.get(Result, (user.id, r.question_id))
        if row is None:
            db.add(Result(user_id=user.id, question_id=r.question_id, correct=r.correct,
                          updated_at=to_utc(r.updated_at)))
        elif to_utc(r.updated_at) >= row.updated_at:
            row.correct, row.updated_at = r.correct, to_utc(r.updated_at)
    db.commit()
    return {'saved': len(existing)}


@router.post('/results/delete')
def delete_results(body: QuestionIds, user: User = Depends(current_user), db: Session = Depends(get_db)):
    if body.question_ids:
        db.execute(delete(Result).where(Result.user_id == user.id,
                                        Result.question_id.in_(body.question_ids)))
        db.commit()
    return {'ok': True}


@router.get('/attempts')
def my_attempts(user: User = Depends(current_user), db: Session = Depends(get_db)):
    return [attempt_json(a) for a in
            db.scalars(select(Attempt).where(Attempt.user_id == user.id).order_by(Attempt.at.desc()))]


@router.post('/attempts', status_code=201)
def add_attempts(body: list[AttemptIn], user: User = Depends(current_user), db: Session = Depends(get_db)):
    decks = set(db.scalars(select(Deck.id)))
    for a in body:
        db.add(Attempt(user_id=user.id, deck_id=a.deck_id if a.deck_id in decks else None,
                       at=to_utc(a.at), total=a.total, right_count=a.right_count,
                       wrong_count=a.wrong_count, seconds=a.seconds))
    db.commit()
    return {'saved': len(body)}


@router.get('/activity')
def my_activity(since: date | None = None, user: User = Depends(current_user),
                db: Session = Depends(get_db)):
    q = select(DailyActivity).where(DailyActivity.user_id == user.id)
    if since:
        q = q.where(DailyActivity.day >= since)
    return [activity_json(a) for a in db.scalars(q)]


@router.post('/activity')
def bump_activity(body: list[ActivityIn], user: User = Depends(current_user), db: Session = Depends(get_db)):
    """Adds counts per day (safe to call from several devices)."""
    for a in body:
        row = db.get(DailyActivity, (user.id, a.day))
        if row is None:
            db.add(DailyActivity(user_id=user.id, day=a.day, count=a.n))
        else:
            row.count += a.n
        db.flush()
    db.commit()
    return {'ok': True}


@router.get('/vocab-progress')
def my_vocab(user: User = Depends(current_user), db: Session = Depends(get_db)):
    return [vocab_json(v) for v in db.scalars(select(VocabProgress).where(VocabProgress.user_id == user.id))]


@router.put('/vocab-progress')
def save_vocab(body: list[VocabProgressIn], user: User = Depends(current_user),
               db: Session = Depends(get_db)):
    for v in body:
        row = db.get(VocabProgress, (user.id, v.word_id))
        if row is None:
            db.add(VocabProgress(user_id=user.id, word_id=v.word_id, known=v.known, correct=v.correct,
                                 wrong=v.wrong, updated_at=to_utc(v.updated_at)))
        elif to_utc(v.updated_at) >= row.updated_at:
            row.known, row.correct, row.wrong = v.known, v.correct, v.wrong
            row.updated_at = to_utc(v.updated_at)
        db.flush()
    db.commit()
    return {'saved': len(body)}
