import os
import tempfile

os.environ['DATABASE_URL'] = 'sqlite:///' + os.path.join(tempfile.mkdtemp(), 'test.db')

from fastapi.testclient import TestClient  # noqa: E402

from app.db import SessionLocal  # noqa: E402
from app.main import app  # noqa: E402
from app.models import User  # noqa: E402


def auth(token):
    return {'Authorization': f'Bearer {token}'}


def signup(c, name, pw='secret123'):
    r = c.post('/auth/register', json={'username': name, 'password': pw})
    assert r.status_code == 200, r.text
    return r.json()


def make_admin(user_id):
    with SessionLocal() as db:
        db.get(User, user_id).role = 'admin'
        db.commit()


DECK = {
    'id': 'd1', 'name': 'Pháp luật', 'questions': [
        {'id': 'd1-0-0', 'section_index': 0, 'section_title': 'Chương 1', 'position': 0, 'number': 1,
         'text': 'Câu hỏi?', 'options': ['A', 'B', 'C', 'D'], 'answer': 2},
    ],
}


def test_full_flow():
    with TestClient(app) as c:
        assert c.get('/').json() == {'ok': True}

        # accounts
        alice = signup(c, 'Alice')
        assert alice['user']['username'] == 'alice'
        assert c.post('/auth/register', json={'username': 'alice', 'password': 'x' * 6}).status_code == 409
        assert c.post('/auth/register', json={'username': 'bob', 'password': '123'}).status_code == 400
        assert c.post('/auth/login', json={'username': 'alice', 'password': 'wrong!'}).status_code == 401
        token = c.post('/auth/login', json={'username': 'ALICE', 'password': 'secret123'}).json()['token']
        assert c.get('/me').status_code == 401
        r = c.patch('/me', headers=auth(token), json={'name': 'Diễn', 'birthday': '2004-08-12'})
        assert r.json()['name'] == 'Diễn' and r.json()['birthday'] == '2004-08-12'

        # avatar
        r = c.put('/me/avatar', headers={**auth(token), 'Content-Type': 'image/png'}, content=b'\x89PNGfake')
        assert r.json()['avatar_path'].endswith('/1')
        me_id = alice['user']['id']
        assert c.get(f'/users/{me_id}/avatar', headers=auth(token)).content == b'\x89PNGfake'

        # content: the owner and admins may edit, others may not
        admin = signup(c, 'admin')
        make_admin(admin['user']['id'])
        bob = signup(c, 'bob')
        assert c.post('/decks', headers=auth(admin['token']), json=DECK).status_code == 201
        assert len(c.get('/questions', headers=auth(token)).json()) == 1
        upd = {'text': 'Sửa?', 'options': ['A', 'B'], 'answer': 1}
        assert c.patch('/questions/d1-0-0', headers=auth(bob['token']), json=upd).status_code == 403
        assert c.patch('/questions/d1-0-0', headers=auth(admin['token']), json=upd).json()['answer'] == 1
        assert c.patch('/questions/d1-0-0', headers=auth(admin['token']),
                       json={**upd, 'answer': 5}).status_code == 400

        # progress (unknown question ids are skipped, newer answer wins)
        res = [{'question_id': 'd1-0-0', 'correct': False, 'updated_at': '2026-10-27T10:00:00Z'},
               {'question_id': 'nope', 'correct': True, 'updated_at': '2026-10-27T10:00:00Z'}]
        assert c.put('/me/results', headers=auth(token), json=res).json()['saved'] == 1
        c.put('/me/results', headers=auth(token),
              json=[{'question_id': 'd1-0-0', 'correct': True, 'updated_at': '2026-10-27T09:00:00Z'}])
        assert c.get('/me/results', headers=auth(token)).json()[0]['correct'] is False
        c.post('/me/attempts', headers=auth(token), json=[
            {'deck_id': 'd1', 'at': '2026-10-27T10:05:00Z', 'total': 1, 'right_count': 0,
             'wrong_count': 1, 'seconds': 30}])
        assert len(c.get('/me/attempts', headers=auth(token)).json()) == 1
        c.post('/me/activity', headers=auth(token), json=[{'day': '2026-10-27', 'n': 3}])
        c.post('/me/activity', headers=auth(token), json=[{'day': '2026-10-27', 'n': 2}])
        assert c.get('/me/activity', headers=auth(token)).json()[0]['count'] == 5
        c.put('/me/vocab-progress', headers=auth(token), json=[
            {'word_id': 'hsk1-爱', 'known': True, 'correct': 2, 'wrong': 0,
             'updated_at': '2026-10-27T10:00:00Z'}])
        assert c.get('/me/vocab-progress', headers=auth(token)).json()[0]['known'] is True

        # vocab lists
        vl = {'id': 'v1', 'name': 'Bài 1', 'words': [{'id': 'v1-0', 'position': 0, 'hanzi': '你好',
                                                       'pinyin': 'nǐ hǎo', 'meaning': 'xin chào'}]}
        assert c.post('/vocab/lists', headers=auth(token), json=vl).status_code == 201
        assert c.delete('/vocab/lists/v1', headers=auth(bob['token'])).status_code == 403
        assert c.patch('/vocab/words/v1-0', headers=auth(token),
                       json={'pinyin': 'nǐhǎo', 'meaning': 'chào'}).status_code == 200

        # admin
        assert c.get('/admin/data', headers=auth(token)).status_code == 403
        data = c.get('/admin/data', headers=auth(admin['token'])).json()
        assert {u['username'] for u in data['users']} == {'alice', 'admin', 'bob'}
        assert len(data['results']) == 1 and data['activity'][0]['count'] == 5
        assert c.get(f'/users/{me_id}/avatar', headers=auth(admin['token'])).status_code == 200
        assert c.get(f'/users/{me_id}/avatar', headers=auth(bob['token'])).status_code == 403
        assert c.patch(f"/admin/users/{admin['user']['id']}", headers=auth(admin['token']),
                       json={'role': 'student'}).status_code == 400
        assert c.patch(f"/admin/users/{bob['user']['id']}", headers=auth(admin['token']),
                       json={'role': 'admin'}).json()['role'] == 'admin'
        assert c.post('/admin/users', headers=auth(admin['token']),
                      json={'username': 'carol', 'password': 'secret123', 'name': 'Carol'}).status_code == 201

        # deleting a deck removes its questions and answers
        assert c.delete('/decks/d1', headers=auth(admin['token'])).status_code == 200
        assert c.get('/me/results', headers=auth(token)).json() == []


def test_ai_explain(monkeypatch):
    from app.routers import ai

    calls = []

    def fake_claude(q, chosen):
        calls.append(chosen)
        return f'Sai vì {chosen}'

    def broken_gemini(q, chosen):
        raise ai.AiUnavailable('hết lượt')

    monkeypatch.setattr(ai, '_client', object())
    monkeypatch.setattr(ai, '_ask_claude', fake_claude)
    monkeypatch.setattr(ai, '_gemini', object())
    monkeypatch.setattr(ai, '_ask_gemini', broken_gemini)  # Claude takes over
    with TestClient(app) as c:
        dana = signup(c, 'dana')
        t = dana['token']
        assert c.post('/decks', headers=auth(t), json={**DECK, 'id': 'd2', 'questions': [
            {**DECK['questions'][0], 'id': 'd2-0-0'}]}).status_code == 201

        ask = lambda chosen: c.post('/ai/explain', headers=auth(t),  # noqa: E731
                                    json={'question_id': 'd2-0-0', 'chosen': chosen})
        assert ask(2).status_code == 400  # the right answer needs no explanation
        assert ask(9).status_code == 400
        assert ask(0).json() == {'text': 'Sai vì 0', 'cached': False}
        assert ask(0).json() == {'text': 'Sai vì 0', 'cached': True}
        assert calls == [0]

        # editing the question drops the stale explanation
        c.patch('/questions/d2-0-0', headers=auth(t),
                json={'text': 'Câu mới?', 'options': ['A', 'B', 'C', 'D'], 'answer': 2})
        assert ask(0).json()['cached'] is False

        monkeypatch.setattr(ai, '_client', None)
        r = ask(1)
        assert r.status_code == 502 and r.json()['detail'] == 'hết lượt'
        monkeypatch.setattr(ai, '_gemini', None)
        assert ask(1).status_code == 503
