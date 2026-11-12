import { router } from 'expo-router';

import { exerciseWord, type Tense, type TenseExercise } from '@/lib/content';
import { shuffle, type WordProgress } from '@/lib/types';

/** Exercises of a tense answered right at least once. */
export const tenseDone = (progress: Record<string, WordProgress>, t: Tense) =>
  t.exercises.filter((e) => (progress[exerciseWord(e).id]?.correct ?? 0) > 0).length;

/** Not-yet-mastered exercises first, then the rest; shuffled within each group. */
export function openTenseQuiz(progress: Record<string, WordProgress>, title: string, all: TenseExercise[], count?: number) {
  const mastered = (e: TenseExercise) => (progress[e.id]?.correct ?? 0) > 0;
  const picked = [...shuffle(all.filter((e) => !mastered(e))), ...shuffle(all.filter(mastered))].slice(0, count ?? all.length);
  router.push({ pathname: '/tense-quiz', params: { title, ids: picked.map((e) => e.id).join(',') } });
}
