// Starting a study session: the session goes in the store (too big for route
// params), then the screen opens.
import { router } from 'expo-router';
import { Alert } from 'react-native';

import { shuffle, type Question, type VocabWord } from '@/lib/types';
import { useStore, type VocabMode } from '@/state/store';

export function startQuiz(title: string, questions: Question[], startAt = 0) {
  if (!questions.length) {
    Alert.alert('Không có câu nào trong mục này');
    return;
  }
  useStore.setState({ quiz: { title, questions, startAt } });
  router.push('/quiz');
}

/** Asks how many questions, then starts a shuffled quiz ("thi thử"). */
export function pickRandomQuiz(title: string, all: Question[]) {
  const counts = [...new Set([10, 20, 30, 50, all.length])].filter((c) => c <= all.length).sort((a, b) => a - b);
  Alert.alert('Bao nhiêu câu?', undefined, [
    ...counts.map((c) => ({
      text: c === all.length ? `Tất cả (${c} câu)` : `${c} câu`,
      onPress: () => startQuiz(`${title} · thi thử`, shuffle(all).slice(0, c)),
    })),
    { text: 'Hủy', style: 'cancel' as const },
  ]);
}

export function startFlashcards(title: string, words: VocabWord[]) {
  if (!words.length) {
    Alert.alert('Không có từ nào để học');
    return;
  }
  useStore.setState({ vocab: { title, words, pool: words, mode: 'hanziToMeaning' } });
  router.push('/flashcards');
}

export function startVocabQuiz(title: string, words: VocabWord[], pool: VocabWord[], mode: VocabMode) {
  if (!words.length) {
    Alert.alert('Không có từ nào để học');
    return;
  }
  useStore.setState({ vocab: { title, words, pool, mode } });
  router.push('/vocab-quiz');
}

export function startPronounce(title: string, words: VocabWord[]) {
  if (!words.length) return;
  useStore.setState({ vocab: { title, words, pool: words, mode: 'listen' } });
  router.push('/pronounce');
}

export function startWriting(title: string, words: VocabWord[]) {
  if (!words.length) return;
  useStore.setState({ vocab: { title, words, pool: words, mode: 'hanziToMeaning' } });
  router.push('/writing');
}
