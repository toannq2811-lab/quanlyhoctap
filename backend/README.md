# Backend — FastAPI + MySQL

```
backend/api/            FastAPI app (deploy lên Render)
  app/main.py           khởi tạo app, CORS, tự tạo bảng khi chạy
  app/models.py         các bảng MySQL (SQLAlchemy)
  app/routers/          auth · content (bộ đề, từ vựng) · progress (kết quả, hoạt động) · admin
  tests/test_api.py     test toàn bộ luồng (chạy trên SQLite)
  scripts/migrate_from_supabase.py   chuyển dữ liệu cũ từ Supabase sang
backend/supabase/       (cũ, không còn dùng) SQL của bản Supabase — giữ để tham khảo
```

- **Đăng nhập**: tên đăng nhập + mật khẩu (bcrypt) → JWT, hạn 60 ngày.
- **Phân quyền**: mỗi người chỉ đọc/ghi dữ liệu của mình; bộ đề / danh sách từ chỉ người tạo hoặc admin sửa được; `/admin/*` chỉ admin.
- **Ảnh đại diện**: lưu trong MySQL (cột MEDIUMBLOB), không cần dịch vụ lưu ảnh riêng.

## Chạy trên máy

```
cd backend/api
python -m venv .venv
.venv\Scripts\pip install -r requirements-dev.txt
.venv\Scripts\python -m pytest                       # test
.venv\Scripts\python -m uvicorn app.main:app --reload --port 8000
```

Không đặt `DATABASE_URL` thì dùng file SQLite `dev.db`. Build app trỏ vào máy:
`flutter build web --dart-define=API_URL=http://127.0.0.1:8000`.

## Deploy

1. **MySQL**: TiDB Cloud (Serverless, miễn phí) → tạo cluster → **Connect** → chọn *SQLAlchemy* →
   lấy chuỗi `mysql+pymysql://USER:PASSWORD@HOST:4000/test`.
2. **Render**: New → **Blueprint** → chọn repo GitHub này (đọc `render.yaml`) →
   điền `DATABASE_URL`. `JWT_SECRET` Render tự sinh.
3. Chuyển dữ liệu cũ (một lần, từ máy tính):
   ```
   set DATABASE_URL=mysql+pymysql://...
   .venv\Scripts\python scripts\migrate_from_supabase.py --admin admin:MAT_KHAU_ADMIN --keep dienxinhgai:MAT_KHAU --keep admin:MAT_KHAU_ADMIN
   ```
4. Địa chỉ API mặc định của app: `https://studyforyou-api.onrender.com` (sửa ở `shared/lib/config.dart` nếu khác).

Render bản free ngủ sau 15 phút không có request; dùng UptimeRobot ping `https://<api>/` mỗi 5 phút
để giữ máy chủ thức.
