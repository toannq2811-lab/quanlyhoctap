// Text-to-speech, speech recognition and pronunciation judging
// (port of frontend/lib/chinese/zh_bridge_web.dart + pronunciation.dart).
import * as Speech from 'expo-speech';
import { ExpoSpeechRecognitionModule } from 'expo-speech-recognition';

/** Reads `text` aloud; Chinese a little slower so tones are easy to hear. */
export function speak(text: string, lang = 'zh-CN', rate?: number) {
  Speech.stop();
  Speech.speak(text, { language: lang, rate: rate ?? (lang.startsWith('zh') ? 0.8 : 0.9) });
}

export class ListenError extends Error {}

/**
 * Listens for one word or phrase and returns what the recognizer heard (best guesses first).
 * Stops by itself 1.2 s after the speaker goes quiet, and after 8 s at most.
 */
export async function listen(lang: string): Promise<string[]> {
  const perm = await ExpoSpeechRecognitionModule.requestPermissionsAsync();
  if (!perm.granted) {
    throw new ListenError('Chưa cho phép micro / nhận dạng giọng nói. Vào Cài đặt iPhone → Study For You để bật nhé.');
  }
  return new Promise((resolve, reject) => {
    let heard: string[] = [];
    let settle: ReturnType<typeof setTimeout> | undefined;
    let finished = false;
    const subs = [
      ExpoSpeechRecognitionModule.addListener('result', (e) => {
        heard = e.results.map((r) => r.transcript).filter(Boolean);
        clearTimeout(settle);
        if (e.isFinal) ExpoSpeechRecognitionModule.stop();
        else settle = setTimeout(() => ExpoSpeechRecognitionModule.stop(), 1200);
      }),
      ExpoSpeechRecognitionModule.addListener('error', (e) => {
        if (e.error === 'no-speech' || e.error === 'aborted') return; // 'end' follows
        done(() => reject(new ListenError(
          e.error === 'not-allowed'
            ? 'Chưa cho phép micro. Vào Cài đặt iPhone → Study For You để bật nhé.'
            : 'Không nghe rõ, thử lại nhé',
        )));
      }),
      ExpoSpeechRecognitionModule.addListener('end', () => done(() => resolve(heard))),
    ];
    const cap = setTimeout(() => ExpoSpeechRecognitionModule.stop(), 8000);
    const hard = setTimeout(() => {
      ExpoSpeechRecognitionModule.abort();
      done(() => resolve(heard));
    }, 12000);

    function done(fn: () => void) {
      if (finished) return;
      finished = true;
      clearTimeout(settle);
      clearTimeout(cap);
      clearTimeout(hard);
      subs.forEach((s) => s.remove());
      fn();
    }

    Speech.stop();
    ExpoSpeechRecognitionModule.start({ lang, interimResults: true, maxAlternatives: 5 });
  });
}

export function stopListening() {
  ExpoSpeechRecognitionModule.abort();
}

// ------------------------------------------------------------------ judging

export type Verdict = 'correct' | 'homophone' | 'wrong';

const toneless: Record<string, string> = {
  ā: 'a', á: 'a', ǎ: 'a', à: 'a', ē: 'e', é: 'e', ě: 'e', è: 'e',
  ī: 'i', í: 'i', ǐ: 'i', ì: 'i', ō: 'o', ó: 'o', ǒ: 'o', ò: 'o',
  ū: 'u', ú: 'u', ǔ: 'u', ù: 'u', ǖ: 'v', ǘ: 'v', ǚ: 'v', ǜ: 'v', ü: 'v',
};

const stripTones = (pinyin: string) =>
  [...pinyin.toLowerCase()].map((c) => toneless[c] ?? c).join('').replace(/[^a-z]/g, '');

/** Only the Chinese characters of a transcript. */
export const chineseOnly = (text: string) => (text.match(/[㐀-鿿豈-﫿]/g) ?? []).join('');

/**
 * Judges what the recognizer heard against the expected word. `charPinyin` lets
 * "他" count as a homophone of "她" (both "ta"): the recognizer can't tell them apart.
 */
export function judgeChinese(target: string, heard: string[], charPinyin: Record<string, string>): Verdict {
  const want = chineseOnly(target);
  const guesses = heard.map(chineseOnly).filter(Boolean);
  if (!want || !guesses.length) return 'wrong';
  if (guesses.some((g) => g === want || g.includes(want))) return 'correct';

  const sound = (chars: string) => {
    const parts: string[] = [];
    for (const c of chars) {
      const p = charPinyin[c];
      if (!p) return null;
      parts.push(stripTones(p));
    }
    return parts.join('');
  };
  const wantSound = sound(want);
  if (wantSound && guesses.some((g) => sound(g) === wantSound)) return 'homophone';
  return 'wrong';
}

/** English: the recognizer heard the target word (or phrase) among its guesses. */
export function judgeEnglish(target: string, heard: string[]): Verdict {
  const norm = (s: string) =>
    s.toLowerCase().replace(/[^a-z' ]/g, ' ').replace(/\s+/g, ' ').trim();
  const want = norm(target);
  if (!want) return 'wrong';
  return heard.some((h) => ` ${norm(h)} `.includes(` ${want} `)) ? 'correct' : 'wrong';
}
