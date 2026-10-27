"""Admin website: everyone's data and account management."""
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import select
from sqlalchemy.orm import Session

from ..db import get_db
from ..models import Attempt, DailyActivity, Result, User, VocabProgress
from ..schemas import AdminUserUpdate, NewUser, profile_json
from ..security import admin_user
from .auth import create_user
from .progress import activity_json, attempt_json, result_json, vocab_json

router = APIRouter(prefix='/admin')


@router.get('/data')
def all_data(_: User = Depends(admin_user), db: Session = Depends(get_db)):
    """Everything the admin pages show, in one request."""
    return {
        'users': [profile_json(u) for u in db.scalars(select(User).order_by(User.created_at))],
        'results': [result_json(r) for r in db.scalars(select(Result))],
        'attempts': [attempt_json(a) for a in db.scalars(select(Attempt).order_by(Attempt.at.desc()))],
        'activity': [activity_json(a) for a in db.scalars(select(DailyActivity))],
        'vocab_progress': [vocab_json(v) for v in db.scalars(select(VocabProgress))],
    }


@router.post('/users', status_code=201)
def new_user(body: NewUser, _: User = Depends(admin_user), db: Session = Depends(get_db)):
    return profile_json(create_user(db, body.username, body.password, body.name))


@router.patch('/users/{user_id}')
def edit_user(user_id: str, body: AdminUserUpdate, me: User = Depends(admin_user),
              db: Session = Depends(get_db)):
    user = db.get(User, user_id)
    if user is None:
        raise HTTPException(404, 'Không tìm thấy tài khoản')
    fields = body.model_dump(exclude_unset=True)
    if 'name' in fields:
        user.name = (fields['name'] or '').strip() or None
    if 'birthday' in fields:
        user.birthday = fields['birthday']
    if 'role' in fields:
        if fields['role'] not in ('student', 'admin'):
            raise HTTPException(400, 'Vai trò không hợp lệ')
        if user.id == me.id:
            raise HTTPException(400, 'Không tự đổi quyền của chính mình được')
        user.role = fields['role']
    db.commit()
    return profile_json(user)
