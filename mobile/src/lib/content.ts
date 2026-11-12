// Built-in content bundled with the app: HSK lists and the beginner English course.
// Generated from ../shared/assets by `npm run data`.
import hsk from '@/data/hsk.json';
import tensesJson from '@/data/english-tenses.json';
import vocabJson from '@/data/english-vocab.json';
import type { VocabList, VocabWord } from './types';

export const hskLists: VocabList[] = hsk.map((l) => ({
  id: l.id,
  name: l.name,
  builtIn: true,
  words: l.words.map((w) => ({ id: w.id, hanzi: w.h, pinyin: w.p, meaning: w.m })),
}));

/** hanzi → pinyin, used to judge homophones in pronunciation practice. */
export const charPinyin: Record<string, string> = {};
for (const l of hskLists) for (const w of l.words) charPinyin[w.hanzi] ??= w.pinyin;

export type TenseExercise = {
  id: string;
  question: string;
  options: string[];
  answer: number;
  explain: string;
};

export type Tense = {
  id: string;
  order: number;
  vi: string;
  en: string;
  summary: string;
  forms: { label: string; formula: string; example: string; exampleVi: string }[];
  usage: { text: string; example: string; exampleVi: string }[];
  signals: string[];
  tips: string[];
  exercises: TenseExercise[];
};

export const tenses: Tense[] = (tensesJson as any[])
  .map((t) => ({
    ...t,
    exercises: (t.exercises as any[]).map((e, i) => ({
      id: `en-tense-${t.id}-${i}`,
      question: e.q,
      options: e.options,
      answer: e.answer,
      explain: e.explain,
    })),
  }))
  .sort((a, b) => a.order - b.order);

export const allExercises = tenses.flatMap((t) => t.exercises);

/** Progress for a tense exercise is stored like a vocabulary word, under its id. */
export const exerciseWord = (e: TenseExercise): VocabWord => ({
  id: e.id,
  hanzi: e.question,
  pinyin: '',
  meaning: e.options[e.answer],
});

export type EnglishTopic = { list: VocabList; icon: string };

export const englishTopics: EnglishTopic[] = (vocabJson as any[]).map((t) => ({
  icon: t.icon ?? '🔤',
  list: {
    id: `en-${t.id}`,
    name: t.name,
    builtIn: true,
    words: (t.words as any[]).map((w) => ({
      id: `en-${t.id}-${w.w}`,
      hanzi: w.w,
      pinyin: w.ipa,
      meaning: w.vi,
      example: w.ex,
      exampleVi: w.exVi,
    })),
  },
}));

export const englishWords = englishTopics.flatMap((t) => t.list.words);
