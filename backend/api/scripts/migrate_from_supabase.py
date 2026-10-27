"""Copy everything from the old Supabase project into the API database.

Supabase never exposes password hashes, so each account to keep needs its password:

    set DATABASE_URL=mysql+pymysql://...      (or leave unset for the local SQLite dev.db)
    python scripts/migrate_from_supabase.py --admin admin:PASSWORD \
        --keep dienxinhgai:PASSWORD --keep admin:PASSWORD

Accounts not listed with --keep are skipped (e.g. test accounts). Safe to re-run:
rows that already exist are left alone.
"""
import argparse
import json
import os
import sys
import urllib.request
from datetime import date, datetime

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from app.db import Base, SessionLocal, engine  # noqa: E402
from app.models import (Attempt, DailyActivity, Deck, Question, Result, User, VocabList,  # noqa: E402
                        VocabProgress, VocabWord)
from app.schemas import to_utc  # noqa: E402
from app.security import hash_password  # noqa: E402

SUPABASE_URL = 'https://tzganoqbmhrhkekjsgwt.supabase.co'
SUPABASE_KEY = 'sb_publishable_86Tvdao9YzkgDd6ZjJfDsA_xgEHxyTY'
EMAIL_DOMAIN = 'studyforyou.app'


def call(method, path, token=None, body=None, raw=False):
    req = urllib.request.Request(
        SUPABASE_URL + path, method=method,
        data=None if body is None else json.dumps(body).encode(),
        headers={'apikey': SUPABASE_KEY, 'Authorization': f'Bearer {token or SUPABASE_KEY}',
                 'Content-Type': 'application/json'})
    with urllib.request.urlopen(req) as res:
        data = res.read()
        return data if raw else json.loads(data or b'null')


def rows(token, table):
    out, page = [], 1000
    while True:
        chunk = call('GET', f'/rest/v1/{table}?select=*&offset={len(out)}&limit={page}', token)
        out += chunk
        if len(chunk) < page:
            return out


def ts(s):
    return to_utc(datetime.fromisoformat(s.replace('Z', '+00:00'))) if s else None


def main():
    for stream in (sys.stdout, sys.stderr):
        stream.reconfigure(encoding='utf-8')
    ap = argparse.ArgumentParser()
    ap.add_argument('--admin', required=True, help='username:password of a Supabase admin')
    ap.add_argument('--keep', action='append', default=[], help='username:password to copy')
    args = ap.parse_args()

    user, pw = args.admin.split(':', 1)
    token = call('POST', '/auth/v1/token?grant_type=password',
                 body={'email': f'{user}@{EMAIL_DOMAIN}', 'password': pw})['access_token']
    keep = dict(k.split(':', 1) for k in args.keep)

    Base.metadata.create_all(engine)
    db = SessionLocal()
    added = {}

    def add(obj, key):
        if db.get(type(obj), key) is None:
            db.add(obj)
            added[type(obj).__name__] = added.get(type(obj).__name__, 0) + 1

    profiles = [p for p in rows(token, 'profiles') if p['username'] in keep]
    kept_ids = {p['id'] for p in profiles}
    for p in profiles:
        u = User(id=p['id'], username=p['username'], password_hash=hash_password(keep[p['username']]),
                 name=p['name'], birthday=date.fromisoformat(p['birthday']) if p['birthday'] else None,
                 role=p['role'], last_seen=ts(p['last_seen']), created_at=ts(p['created_at']))
        if p['avatar_path']:
            u.avatar = call('GET', f"/storage/v1/object/authenticated/avatars/{p['avatar_path']}", token, raw=True)
            u.avatar_type = 'image/jpeg' if p['avatar_path'].endswith('.jpg') else 'image/png'
            u.avatar_version = 1
        add(u, u.id)
    db.flush()

    owner = lambda uid: uid if uid in kept_ids else None  # noqa: E731
    for d in rows(token, 'decks'):
        add(Deck(id=d['id'], name=d['name'], position=d['position'], created_by=owner(d['created_by']),
                 created_at=ts(d['created_at'])), d['id'])
    db.flush()
    for q in rows(token, 'questions'):
        add(Question(id=q['id'], deck_id=q['deck_id'], section_index=q['section_index'],
                     section_title=q['section_title'], position=q['position'], number=q['number'],
                     text=q['text'], options=q['options'], answer=q['answer'],
                     explanation=q['explanation']), q['id'])
    db.flush()
    for r in rows(token, 'results'):
        if r['user_id'] in kept_ids:
            add(Result(user_id=r['user_id'], question_id=r['question_id'], correct=r['correct'],
                       updated_at=ts(r['updated_at'])), (r['user_id'], r['question_id']))
    for a in rows(token, 'attempts'):
        if a['user_id'] in kept_ids:
            db.add(Attempt(user_id=a['user_id'], deck_id=a['deck_id'], at=ts(a['at']), total=a['total'],
                           right_count=a['right_count'], wrong_count=a['wrong_count'], seconds=a['seconds']))
    for a in rows(token, 'daily_activity'):
        if a['user_id'] in kept_ids:
            add(DailyActivity(user_id=a['user_id'], day=date.fromisoformat(a['day']), count=a['count']),
                (a['user_id'], date.fromisoformat(a['day'])))
    for v in rows(token, 'vocab_lists'):
        add(VocabList(id=v['id'], name=v['name'], position=v['position'], created_by=owner(v['created_by']),
                      created_at=ts(v['created_at'])), v['id'])
    db.flush()
    for w in rows(token, 'vocab_words'):
        add(VocabWord(id=w['id'], list_id=w['list_id'], position=w['position'], hanzi=w['hanzi'],
                      pinyin=w['pinyin'], meaning=w['meaning']), w['id'])
    for v in rows(token, 'vocab_progress'):
        if v['user_id'] in kept_ids:
            add(VocabProgress(user_id=v['user_id'], word_id=v['word_id'], known=v['known'],
                              correct=v['correct'], wrong=v['wrong'], updated_at=ts(v['updated_at'])),
                (v['user_id'], v['word_id']))
    db.commit()
    print('Đã chuyển:', ', '.join(f'{k} {v}' for k, v in added.items()) or 'không có gì mới')
    skipped = {p['username'] for p in rows(token, 'profiles')} - set(keep)
    if skipped:
        print('Bỏ qua tài khoản:', ', '.join(sorted(skipped)))


if __name__ == '__main__':
    main()
