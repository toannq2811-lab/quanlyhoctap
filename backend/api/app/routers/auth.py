"""Sign-up / login, the signed-in user's profile and avatars."""
import re
import uuid

from fastapi import APIRouter, Depends, HTTPException, Request, Response
from sqlalchemy import select
from sqlalchemy.orm import Session, undefer

from ..config import MAX_AVATAR_BYTES
from ..db import get_db
from ..models import User, utcnow
from ..schemas import Credentials, ProfileUpdate, profile_json
from ..security import check_password, current_user, hash_password, make_token

router = APIRouter()

USERNAME_RE = re.compile(r'^[a-z0-9._-]{3,30}$')


def create_user(db: Session, username: str, password: str, name: str | None = None) -> User:
    username = username.strip().lower()
    if not USERNAME_RE.match(username):
        raise HTTPException(400, 'Tên đăng nhập chỉ gồm chữ không dấu, số, dấu . _ - (3–30 ký tự)')
    if len(password) < 6:
        raise HTTPException(400, 'Mật khẩu cần ít nhất 6 ký tự')
    if db.scalar(select(User).where(User.username == username)):
        raise HTTPException(409, 'Tên này đã có người dùng')
    user = User(id=str(uuid.uuid4()), username=username, password_hash=hash_password(password),
                name=(name or '').strip() or None)
    db.add(user)
    db.commit()
    return user


@router.post('/auth/register')
def register(body: Credentials, db: Session = Depends(get_db)):
    user = create_user(db, body.username, body.password)
    return {'token': make_token(user), 'user': profile_json(user)}


@router.post('/auth/login')
def login(body: Credentials, db: Session = Depends(get_db)):
    user = db.scalar(select(User).where(User.username == body.username.strip().lower()))
    if user is None or not check_password(body.password, user.password_hash):
        raise HTTPException(401, 'Sai tên đăng nhập hoặc mật khẩu')
    return {'token': make_token(user), 'user': profile_json(user)}


@router.get('/me')
def me(user: User = Depends(current_user)):
    return profile_json(user)


@router.patch('/me')
def update_me(body: ProfileUpdate, user: User = Depends(current_user), db: Session = Depends(get_db)):
    fields = body.model_dump(exclude_unset=True)
    if 'name' in fields:
        user.name = (fields['name'] or '').strip() or None
    if 'birthday' in fields:
        user.birthday = fields['birthday']
    db.commit()
    return profile_json(user)


@router.post('/me/seen')
def seen(user: User = Depends(current_user), db: Session = Depends(get_db)):
    user.last_seen = utcnow()
    db.commit()
    return {'ok': True}


@router.put('/me/avatar')
async def put_avatar(request: Request, user: User = Depends(current_user), db: Session = Depends(get_db)):
    data = await request.body()
    kind = request.headers.get('content-type', 'image/png').split(';')[0]
    if not data or len(data) > MAX_AVATAR_BYTES:
        raise HTTPException(400, 'Ảnh trống hoặc lớn hơn 2MB')
    if not kind.startswith('image/'):
        raise HTTPException(400, 'File không phải ảnh')
    user.avatar = data
    user.avatar_type = kind
    user.avatar_version = (user.avatar_version or 0) + 1
    db.commit()
    return profile_json(user)


@router.delete('/me/avatar')
def delete_avatar(user: User = Depends(current_user), db: Session = Depends(get_db)):
    user.avatar = None
    user.avatar_type = None
    user.avatar_version = (user.avatar_version or 0) + 1
    db.commit()
    return profile_json(user)


@router.get('/users/{user_id}/avatar')
def get_avatar(user_id: str, me: User = Depends(current_user), db: Session = Depends(get_db)):
    if me.id != user_id and me.role != 'admin':
        raise HTTPException(403, 'Không xem được ảnh của người khác')
    target = db.scalar(select(User).options(undefer(User.avatar)).where(User.id == user_id))
    if target is None or target.avatar is None:
        raise HTTPException(404, 'Chưa có ảnh')
    return Response(target.avatar, media_type=target.avatar_type or 'image/png',
                    headers={'Cache-Control': 'private, max-age=86400'})
