from datetime import datetime, timedelta, timezone

import bcrypt
import jwt
from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from sqlalchemy.orm import Session

from .config import JWT_SECRET, TOKEN_HOURS
from .db import get_db
from .models import User

_bearer = HTTPBearer(auto_error=False)


def hash_password(password: str) -> str:
    return bcrypt.hashpw(password.encode(), bcrypt.gensalt()).decode()


def check_password(password: str, hashed: str) -> bool:
    try:
        return bcrypt.checkpw(password.encode(), hashed.encode())
    except ValueError:
        return False


def make_token(user: User) -> str:
    exp = datetime.now(timezone.utc) + timedelta(hours=TOKEN_HOURS)
    return jwt.encode({'sub': user.id, 'exp': exp}, JWT_SECRET, algorithm='HS256')


def current_user(
    cred: HTTPAuthorizationCredentials | None = Depends(_bearer),
    db: Session = Depends(get_db),
) -> User:
    if cred is None:
        raise HTTPException(status.HTTP_401_UNAUTHORIZED, 'Chưa đăng nhập')
    try:
        user_id = jwt.decode(cred.credentials, JWT_SECRET, algorithms=['HS256'])['sub']
    except jwt.PyJWTError:
        raise HTTPException(status.HTTP_401_UNAUTHORIZED, 'Phiên đăng nhập hết hạn')
    user = db.get(User, user_id)
    if user is None:
        raise HTTPException(status.HTTP_401_UNAUTHORIZED, 'Tài khoản không còn tồn tại')
    return user


def admin_user(user: User = Depends(current_user)) -> User:
    if user.role != 'admin':
        raise HTTPException(status.HTTP_403_FORBIDDEN, 'Cần quyền quản trị')
    return user


def can_edit(owner_id: str | None, user: User) -> bool:
    return user.role == 'admin' or (owner_id is not None and owner_id == user.id)
