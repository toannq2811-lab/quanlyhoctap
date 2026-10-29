"""AI explanations: why the option a learner picked is wrong (Gemini or Claude, cached per option)."""
import logging

import anthropic
from google import genai
from google.genai import errors as genai_errors
from google.genai import types as genai_types
from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel
from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm import Session

from ..config import AI_MODEL, ANTHROPIC_API_KEY, GEMINI_API_KEY, GEMINI_MODEL
from ..db import get_db
from ..models import AiExplanation, Question, User
from ..security import current_user

router = APIRouter()
log = logging.getLogger(__name__)

_client = anthropic.Anthropic(api_key=ANTHROPIC_API_KEY, timeout=60.0) if ANTHROPIC_API_KEY else None
_gemini = (genai.Client(api_key=GEMINI_API_KEY, http_options=genai_types.HttpOptions(timeout=60_000))
           if GEMINI_API_KEY else None)


class AiUnavailable(Exception):
    """A provider could not answer; carries the message shown to the learner."""

SYSTEM = """Bạn là gia sư ôn thi trắc nghiệm cho sinh viên Việt Nam, giọng thân thiện, dễ hiểu.
Học viên vừa chọn sai một đáp án. Hãy giải thích bằng tiếng Việt:
1. Vì sao đáp án học viên chọn là sai (chỉ ra chỗ nhầm lẫn hay gặp).
2. Vì sao đáp án đúng mới đúng, nêu căn cứ (khái niệm, điều luật, văn bản pháp luật nếu có).
3. Một mẹo ngắn để nhớ.
Đáp án đúng đã được cho sẵn theo tài liệu; hãy giải thích theo đáp án đó, không tranh luận lại.
Viết ngắn gọn khoảng 80–150 từ, văn bản thuần (không dùng markdown, không dùng ký hiệu ** hay #),
mỗi ý một đoạn ngắn."""


class ExplainIn(BaseModel):
    question_id: str
    chosen: int


def _letter(i: int) -> str:
    return chr(65 + i)


def _prompt(q: Question, chosen: int) -> str:
    options = '\n'.join(f'{_letter(i)}. {o}' for i, o in enumerate(q.options))
    return (f'Môn/chương: {q.section_title}\n\n'
            f'Câu hỏi: {q.text}\n{options}\n\n'
            f'Đáp án đúng: {_letter(q.answer)}. {q.options[q.answer]}\n'
            f'Học viên đã chọn: {_letter(chosen)}. {q.options[chosen]}')


def _ask_gemini(q: Question, chosen: int) -> str:
    try:
        response = _gemini.models.generate_content(
            model=GEMINI_MODEL,
            contents=_prompt(q, chosen),
            config=genai_types.GenerateContentConfig(system_instruction=SYSTEM),
        )
    except genai_errors.APIError as e:
        log.warning('Gemini error %s: %s', e.code, e.message)
        raise AiUnavailable('AI đang bận, thử lại sau ít phút nhé' if e.code == 429
                            else 'AI đang gặp lỗi, thử lại sau nhé')
    except Exception as e:  # timeouts and network errors
        log.warning('Gemini unreachable: %r', e)
        raise AiUnavailable('Không kết nối được tới AI')
    text = (response.text or '').strip()
    if not text:
        raise AiUnavailable('AI không giải thích được câu này')
    return text


def _ask_claude(q: Question, chosen: int) -> str:
    try:
        response = _client.beta.messages.create(
            model=AI_MODEL,
            max_tokens=16000,
            output_config={'effort': 'medium'},
            betas=['server-side-fallback-2026-07-01'],
            fallbacks='default',
            system=SYSTEM,
            messages=[{'role': 'user', 'content': _prompt(q, chosen)}],
        )
    except anthropic.RateLimitError:
        raise AiUnavailable('AI đang bận, thử lại sau ít phút nhé')
    except anthropic.APIStatusError as e:
        log.warning('Claude error %s: %s', e.status_code, e.message)
        raise AiUnavailable('AI đang gặp lỗi, thử lại sau nhé')
    except anthropic.APIConnectionError:
        raise AiUnavailable('Không kết nối được tới AI')
    if response.stop_reason == 'refusal':
        raise AiUnavailable('AI không giải thích được câu này')
    text = ''.join(b.text for b in response.content if b.type == 'text').strip()
    if not text:
        raise AiUnavailable('AI chưa trả lời được, thử lại sau nhé')
    return text


def _providers():
    """Gemini first (free tier), then Claude."""
    if _gemini is not None:
        yield _ask_gemini
    if _client is not None:
        yield _ask_claude


@router.post('/ai/explain')
def explain(body: ExplainIn, _: User = Depends(current_user), db: Session = Depends(get_db)):
    q = db.get(Question, body.question_id)
    if q is None:
        raise HTTPException(404, 'Không tìm thấy câu hỏi')
    if q.answer is None or not 0 <= body.chosen < len(q.options) or body.chosen == q.answer:
        raise HTTPException(400, 'Chỉ giải thích được đáp án sai của câu có đáp án')

    cached = db.get(AiExplanation, (q.id, body.chosen))
    if cached:
        return {'text': cached.text, 'cached': True}
    providers = list(_providers())
    if not providers:
        raise HTTPException(503, 'AI chưa được bật trên máy chủ')

    text, error = None, None
    for ask in providers:
        try:
            text = ask(q, body.chosen)
            break
        except AiUnavailable as e:
            error = e
    if text is None:
        raise HTTPException(502, str(error))

    db.add(AiExplanation(question_id=q.id, chosen=body.chosen, text=text))
    try:
        db.commit()
    except IntegrityError:  # another request for the same option finished first
        db.rollback()
    return {'text': text, 'cached': False}
