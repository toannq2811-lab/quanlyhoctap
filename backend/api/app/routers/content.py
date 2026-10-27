"""Shared content: quiz decks / questions and imported vocabulary lists."""
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import select
from sqlalchemy.orm import Session

from ..db import get_db
from ..models import Deck, Question, User, VocabList, VocabWord
from ..schemas import DeckIn, DeckUpdate, QuestionUpdate, VocabListIn, WordUpdate
from ..security import can_edit, current_user

router = APIRouter()


def question_json(q: Question) -> dict:
    return {
        'id': q.id, 'deck_id': q.deck_id, 'section_index': q.section_index,
        'section_title': q.section_title, 'position': q.position, 'number': q.number,
        'text': q.text, 'options': q.options, 'answer': q.answer, 'explanation': q.explanation,
    }


# ------------------------------------------------------------------ decks

@router.get('/decks')
def list_decks(_: User = Depends(current_user), db: Session = Depends(get_db)):
    return [{'id': d.id, 'name': d.name, 'position': d.position, 'created_by': d.created_by}
            for d in db.scalars(select(Deck).order_by(Deck.position, Deck.created_at))]


@router.get('/questions')
def list_questions(_: User = Depends(current_user), db: Session = Depends(get_db)):
    return [question_json(q) for q in db.scalars(select(Question))]


@router.post('/decks', status_code=201)
def create_deck(body: DeckIn, user: User = Depends(current_user), db: Session = Depends(get_db)):
    if db.get(Deck, body.id):
        raise HTTPException(409, 'Bộ đề đã tồn tại')
    db.add(Deck(id=body.id, name=body.name, position=body.position, created_by=user.id))
    db.flush()
    db.add_all(Question(deck_id=body.id, **q.model_dump()) for q in body.questions)
    db.commit()
    return {'id': body.id, 'questions': len(body.questions)}


def _own_deck(db: Session, deck_id: str, user: User) -> Deck:
    deck = db.get(Deck, deck_id)
    if deck is None:
        raise HTTPException(404, 'Không tìm thấy bộ đề')
    if not can_edit(deck.created_by, user):
        raise HTTPException(403, 'Chỉ người đã thêm bộ đề (hoặc admin) mới sửa được')
    return deck


@router.patch('/decks/{deck_id}')
def rename_deck(deck_id: str, body: DeckUpdate, user: User = Depends(current_user),
                db: Session = Depends(get_db)):
    _own_deck(db, deck_id, user).name = body.name
    db.commit()
    return {'ok': True}


@router.delete('/decks/{deck_id}')
def delete_deck(deck_id: str, user: User = Depends(current_user), db: Session = Depends(get_db)):
    db.delete(_own_deck(db, deck_id, user))
    db.commit()
    return {'ok': True}


@router.patch('/questions/{question_id}')
def update_question(question_id: str, body: QuestionUpdate, user: User = Depends(current_user),
                    db: Session = Depends(get_db)):
    q = db.get(Question, question_id)
    if q is None:
        raise HTTPException(404, 'Không tìm thấy câu hỏi')
    _own_deck(db, q.deck_id, user)
    if body.answer is not None and not 0 <= body.answer < len(body.options):
        raise HTTPException(400, 'Đáp án không nằm trong các lựa chọn')
    q.text, q.options, q.answer, q.explanation = body.text, body.options, body.answer, body.explanation
    db.commit()
    return question_json(q)


@router.delete('/questions/{question_id}')
def delete_question(question_id: str, user: User = Depends(current_user), db: Session = Depends(get_db)):
    q = db.get(Question, question_id)
    if q is None:
        raise HTTPException(404, 'Không tìm thấy câu hỏi')
    _own_deck(db, q.deck_id, user)
    db.delete(q)
    db.commit()
    return {'ok': True}


# ------------------------------------------------------------------ vocabulary

@router.get('/vocab/lists')
def list_vocab(_: User = Depends(current_user), db: Session = Depends(get_db)):
    return [{'id': v.id, 'name': v.name, 'position': v.position, 'created_by': v.created_by}
            for v in db.scalars(select(VocabList).order_by(VocabList.position, VocabList.created_at))]


@router.get('/vocab/words')
def list_words(_: User = Depends(current_user), db: Session = Depends(get_db)):
    return [{'id': w.id, 'list_id': w.list_id, 'position': w.position, 'hanzi': w.hanzi,
             'pinyin': w.pinyin, 'meaning': w.meaning} for w in db.scalars(select(VocabWord))]


@router.post('/vocab/lists', status_code=201)
def create_vocab(body: VocabListIn, user: User = Depends(current_user), db: Session = Depends(get_db)):
    if db.get(VocabList, body.id):
        raise HTTPException(409, 'Danh sách đã tồn tại')
    db.add(VocabList(id=body.id, name=body.name, position=body.position, created_by=user.id))
    db.flush()
    db.add_all(VocabWord(list_id=body.id, **w.model_dump()) for w in body.words)
    db.commit()
    return {'id': body.id, 'words': len(body.words)}


@router.delete('/vocab/lists/{list_id}')
def delete_vocab(list_id: str, user: User = Depends(current_user), db: Session = Depends(get_db)):
    lst = db.get(VocabList, list_id)
    if lst is None:
        raise HTTPException(404, 'Không tìm thấy danh sách')
    if not can_edit(lst.created_by, user):
        raise HTTPException(403, 'Chỉ người đã thêm danh sách (hoặc admin) mới xóa được')
    db.delete(lst)
    db.commit()
    return {'ok': True}


@router.patch('/vocab/words/{word_id}')
def update_word(word_id: str, body: WordUpdate, user: User = Depends(current_user),
                db: Session = Depends(get_db)):
    w = db.get(VocabWord, word_id)
    if w is None:
        raise HTTPException(404, 'Không tìm thấy từ')
    if not can_edit(db.get(VocabList, w.list_id).created_by, user):
        raise HTTPException(403, 'Không có quyền sửa từ này')
    w.pinyin, w.meaning = body.pinyin, body.meaning
    db.commit()
    return {'ok': True}
