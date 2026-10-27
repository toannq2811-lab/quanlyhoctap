# Study For You

Web app ôn tập trắc nghiệm + tiếng Trung, kèm web quản trị để theo dõi tiến độ.

```
frontend/   App học (Flutter web/PWA)          → Netlify: dienham.netlify.app
admin/      Web quản trị (Flutter web, riêng)  → Netlify: dienham-admin.netlify.app
shared/     Code dùng chung: theme, model, đọc PDF/Word, từ vựng HSK, địa chỉ API
backend/    API FastAPI + MySQL (deploy Render), xem backend/README.md
```

Cả app học và web quản trị gọi chung một API (backend/api).

## Build & deploy

```
cd frontend && flutter build web --release   # → kéo frontend/build/web lên site app học
cd admin    && flutter build web --release   # → kéo admin/build/web lên site quản trị
```

## Code

- `shared/lib/config.dart`: địa chỉ API và web quản trị. `shared/lib/api.dart`: client gọi API.
- `shared/lib/parser.dart`: tách câu hỏi / đáp án từ PDF, Word, TXT.
- `frontend/lib/storage.dart`: đồng bộ API ↔ cache Isar trên máy (làm bài được khi mất mạng).
  Sau khi sửa `frontend/lib/db.dart`: `dart run build_runner build`.
- `frontend/lib/pages/`: màn hình app học. `admin/lib/pages/`: màn hình quản trị.
- Test: `cd frontend && flutter test`.
