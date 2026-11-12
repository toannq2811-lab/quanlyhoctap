export type Profile = {
  id: string;
  username: string;
  name: string | null;
  birthday: string | null; // "2004-08-12"
  avatar_path: string | null;
  role: 'student' | 'admin';
};

export type Question = {
  id: string;
  number: number;
  text: string;
  options: string[];
  answer: number | null;
  explanation: string | null;
};

export type Section = { title: string; questions: Question[] };

export type Deck = { id: string; name: string; sections: Section[] };

/** A vocabulary item. For English words (ids starting with "en-") `hanzi` is the
 * English word and `pinyin` its IPA. */
export type VocabWord = {
  id: string;
  hanzi: string;
  pinyin: string;
  meaning: string;
  example?: string;
  exampleVi?: string;
};

export type VocabList = {
  id: string;
  name: string;
  words: VocabWord[];
  builtIn: boolean;
  createdBy?: string | null;
};

export type WordProgress = { known: boolean; correct: number; wrong: number };

export type Attempt = {
  deckId: string | null;
  at: string;
  total: number;
  right: number;
  wrong: number;
  seconds: number;
};

export const isEnglish = (w: VocabWord) => w.id.startsWith('en-');
export const speechLang = (w: VocabWord) => (isEnglish(w) ? 'en-US' : 'zh-CN');
export const allQuestions = (d: Deck) => d.sections.flatMap((s) => s.questions);

export function shuffle<T>(items: T[]): T[] {
  const a = [...items];
  for (let i = a.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [a[i], a[j]] = [a[j], a[i]];
  }
  return a;
}

export const letter = (i: number) => String.fromCharCode(65 + i);

/** "Chương 1: Nhà nước…" → "Chương 1". */
export function shortSectionName(title: string): string {
  const m = /^(chương|phần|bài)\s*[\dIVXLC]+/i.exec(title.trim());
  return m ? m[0] : title.length > 28 ? title.slice(0, 26) + '…' : title;
}

export function formatDuration(sec: number): string {
  const h = Math.floor(sec / 3600);
  const m = String(Math.floor(sec / 60) % 60).padStart(2, '0');
  const s = String(sec % 60).padStart(2, '0');
  return h ? `${h}:${m}:${s}` : `${m}:${s}`;
}
