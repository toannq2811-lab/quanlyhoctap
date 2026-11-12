// The signed-in user's data. The API server is the source of truth; AsyncStorage
// keeps a copy so the app opens and records answers offline, pushing what was
// recorded offline on the next sync. (Port of frontend/lib/storage.dart.)
import AsyncStorage from '@react-native-async-storage/async-storage';
import * as SecureStore from 'expo-secure-store';
import { create } from 'zustand';

import { api, ApiError } from '@/lib/api';
import { hskLists } from '@/lib/content';
import type { Attempt, Deck, Profile, Question, Section, VocabList, VocabWord, WordProgress } from '@/lib/types';

type PendingResult = { correct: boolean; updated_at: string };
type PendingVocab = WordProgress & { updated_at: string };
type Pending = {
  results: Record<string, PendingResult>;
  attempts: Attempt[];
  activity: Record<string, number>;
  vocab: Record<string, PendingVocab>;
};

type Cache = {
  decks: Deck[];
  results: Record<string, boolean>;
  attempts: Attempt[];
  activity: Record<string, number>;
  vocabProgress: Record<string, WordProgress>;
  customLists: VocabList[];
};

/** What a quiz / flashcard screen should show; set right before navigating. */
export type QuizSession = { title: string; questions: Question[]; startAt: number };
export type VocabMode = 'hanziToMeaning' | 'meaningToHanzi' | 'listen';
export type VocabSession = { title: string; words: VocabWord[]; pool: VocabWord[]; mode: VocabMode };

type State = Cache & {
  booted: boolean;
  profile: Profile | null;
  lastUser: string | null;
  savedPassword: string | null;
  offline: boolean;
  syncing: boolean;
  dailyGoal: number;
  /** Set when the server said the login ran out; the login screen shows it once. */
  expiredNotice: boolean;
  quiz: QuizSession | null;
  vocab: VocabSession | null;
};

const SECURE = { token: 'api_token', remember: 'remember', lastUser: 'last_user', password: 'saved_password' };
const emptyPending = (): Pending => ({ results: {}, attempts: [], activity: {}, vocab: {} });
const emptyCache = (): Cache => ({
  decks: [],
  results: {},
  attempts: [],
  activity: {},
  vocabProgress: {},
  customLists: [],
});

export const useStore = create<State>(() => ({
  ...emptyCache(),
  booted: false,
  profile: null,
  lastUser: null,
  savedPassword: null,
  offline: false,
  syncing: false,
  dailyGoal: 20,
  expiredNotice: false,
  quiz: null,
  vocab: null,
}));

const set = useStore.setState;
const get = useStore.getState;

// ------------------------------------------------------------------ local storage

const uid = () => get().profile?.id ?? '';
const cacheKey = () => `cache:${uid()}`;
const pendingKey = () => `pending:${uid()}`;

async function readJson<T>(key: string, fallback: T): Promise<T> {
  try {
    const raw = await AsyncStorage.getItem(key);
    return raw ? (JSON.parse(raw) as T) : fallback;
  } catch {
    return fallback;
  }
}

const writeJson = (key: string, value: unknown) => AsyncStorage.setItem(key, JSON.stringify(value)).catch(() => {});

function saveCache() {
  const s = get();
  const cache: Cache = {
    decks: s.decks,
    results: s.results,
    attempts: s.attempts,
    activity: s.activity,
    vocabProgress: s.vocabProgress,
    customLists: s.customLists,
  };
  return writeJson(cacheKey(), cache);
}

// Serialized so two quick answers never overwrite each other's pending rows.
let pendingLock: Promise<unknown> = Promise.resolve();
function updatePending(fn: (p: Pending) => void) {
  const run = pendingLock.then(async () => {
    const p = await readJson(pendingKey(), emptyPending());
    fn(p);
    await writeJson(pendingKey(), p);
  });
  pendingLock = run.catch(() => {});
  return run;
}

const secureGet = (k: string) => SecureStore.getItemAsync(k).catch(() => null);
const secureSet = (k: string, v: string | null) =>
  (v == null ? SecureStore.deleteItemAsync(k) : SecureStore.setItemAsync(k, v)).catch(() => {});

// ------------------------------------------------------------------ session

function setToken(token: string | null) {
  api.token = token;
  return secureSet(SECURE.token, token);
}

/** The server rejected the token: forget it and show the login screen. */
function expire() {
  if (!get().profile) return;
  setToken(null);
  set({ profile: null, expiredNotice: true, quiz: null, vocab: null });
}
api.onUnauthorized(expire);

/** Reads the saved login; restores the session when "Nhớ mật khẩu" was on. */
export async function boot() {
  const [token, remember, lastUser, savedPassword, goal] = await Promise.all([
    secureGet(SECURE.token),
    secureGet(SECURE.remember),
    secureGet(SECURE.lastUser),
    secureGet(SECURE.password),
    AsyncStorage.getItem('daily_goal').catch(() => null),
  ]);
  set({ lastUser, savedPassword, dailyGoal: Number(goal) || 20 });
  api.token = token;
  if (token && remember === '1') {
    const profile = await loadProfile();
    if (profile?.name) await openUser(profile);
  } else if (token) {
    await setToken(null);
  }
  set({ booted: true });
}

/** The signed-in user's profile (the cached copy when offline). */
async function loadProfile(): Promise<Profile | null> {
  try {
    const p = await api.get<Profile>('/me');
    await AsyncStorage.setItem(`profile:${p.username}`, JSON.stringify(p));
    return p;
  } catch (e) {
    if (e instanceof ApiError && e.offline) {
      const username = await secureGet(SECURE.lastUser);
      return username ? readJson<Profile | null>(`profile:${username}`, null) : null;
    }
    await setToken(null);
    return null;
  }
}

/** Cached name of a user, so the login screen can greet without the network. */
export async function cachedProfile(username: string): Promise<Profile | null> {
  return readJson<Profile | null>(`profile:${username.trim().toLowerCase()}`, null);
}

async function signIn(path: string, username: string, password: string): Promise<Profile> {
  api.token = null;
  const res = await api.post<{ token: string; user: Profile }>(path, { username, password });
  await setToken(res.token);
  await AsyncStorage.setItem(`profile:${res.user.username}`, JSON.stringify(res.user));
  await secureSet(SECURE.lastUser, res.user.username);
  set({ lastUser: res.user.username });
  return res.user;
}

/** Signs in; returns the profile (its name is null until the profile is set up). */
export async function login(username: string, password: string, remember: boolean) {
  const user = username.trim().toLowerCase();
  if (!user || !password) throw new ApiError(400, 'Nhập tên đăng nhập và mật khẩu nhé');
  const profile = await signIn('/auth/login', user, password);
  await secureSet(SECURE.remember, remember ? '1' : null);
  await secureSet(SECURE.password, remember ? password : null);
  set({ savedPassword: remember ? password : null, expiredNotice: false });
  if (profile.name) await openUser(profile);
  return profile;
}

export async function register(username: string, password: string) {
  const user = username.trim().toLowerCase();
  if (!user || !password) throw new ApiError(400, 'Nhập tên đăng nhập và mật khẩu nhé');
  if (!/^[a-z0-9._-]{3,30}$/.test(user)) {
    throw new ApiError(400, 'Tên đăng nhập chỉ gồm chữ không dấu, số, dấu . _ - (3–30 ký tự)');
  }
  if (password.length < 6) throw new ApiError(400, 'Mật khẩu cần ít nhất 6 ký tự');
  return signIn('/auth/register', user, password);
}

/** Saves the name and birthday entered after creating the account. */
export async function saveProfile(name: string, birthday: string) {
  const p = await api.patch<Profile>('/me', { name: name.trim(), birthday });
  await AsyncStorage.setItem(`profile:${p.username}`, JSON.stringify(p));
  return p;
}

export async function logout() {
  await secureSet(SECURE.remember, null);
  await setToken(null);
  set({ ...emptyCache(), profile: null, quiz: null, vocab: null });
}

/** Loads the user's cached data, then syncs with the server. */
export async function openUser(profile: Profile) {
  set({ profile });
  const cache = await readJson(cacheKey(), emptyCache());
  set({ ...cache });
  await sync();
}

// ------------------------------------------------------------------ sync

/** Pushes what was recorded offline, then pulls everything from the server. */
export async function sync() {
  if (!get().profile || get().syncing) return;
  set({ syncing: true });
  try {
    await pushPending();
    const [decks, questions, results, attempts, lists, words, progress] = await Promise.all([
      api.get<any[]>('/decks'),
      api.get<any[]>('/questions'),
      api.get<any[]>('/me/results'),
      api.get<any[]>('/me/attempts'),
      api.get<any[]>('/vocab/lists'),
      api.get<any[]>('/vocab/words'),
      api.get<any[]>('/me/vocab-progress'),
    ]);
    const since = dayKey(new Date(Date.now() - 60 * 86_400_000));
    const activityRows = await api.get<any[]>('/me/activity', { since });
    const pending = await readJson(pendingKey(), emptyPending());

    const activity: Record<string, number> = {};
    for (const r of activityRows) activity[r.day] = r.count;
    for (const [day, n] of Object.entries(pending.activity)) activity[day] = (activity[day] ?? 0) + n;

    set({
      decks: buildDecks(decks, questions),
      results: Object.fromEntries(results.map((r) => [r.question_id, r.correct])),
      attempts: attempts.map((a) => ({
        deckId: a.deck_id,
        at: a.at,
        total: a.total,
        right: a.right_count,
        wrong: a.wrong_count,
        seconds: a.seconds,
      })),
      activity,
      customLists: buildLists(lists, words),
      vocabProgress: Object.fromEntries(
        progress.map((p) => [p.word_id, { known: p.known, correct: p.correct, wrong: p.wrong }]),
      ),
      offline: false,
    });
    api.post('/me/seen').catch(() => {});
    const profile = await loadProfile();
    if (profile && get().profile) set({ profile });
    await saveCache();
  } catch (e) {
    if (!(e instanceof ApiError && e.status === 401)) set({ offline: true });
  } finally {
    set({ syncing: false });
  }
}

function buildDecks(deckRows: any[], questionRows: any[]): Deck[] {
  const byDeck = new Map<string, any[]>();
  for (const q of questionRows) {
    if (!byDeck.has(q.deck_id)) byDeck.set(q.deck_id, []);
    byDeck.get(q.deck_id)!.push(q);
  }
  return [...deckRows]
    .sort((a, b) => a.position - b.position)
    .map((d) => {
      const qs = (byDeck.get(d.id) ?? []).sort((a, b) =>
        a.section_index !== b.section_index ? a.section_index - b.section_index : a.position - b.position,
      );
      const sections: Section[] = [];
      for (const q of qs) {
        if (!sections.length || sections[sections.length - 1].title !== q.section_title) {
          sections.push({ title: q.section_title, questions: [] });
        }
        sections[sections.length - 1].questions.push({
          id: q.id,
          number: q.number,
          text: q.text,
          options: q.options,
          answer: q.answer,
          explanation: q.explanation,
        });
      }
      return { id: d.id, name: d.name, sections };
    });
}

function buildLists(listRows: any[], wordRows: any[]): VocabList[] {
  return listRows.map((l) => ({
    id: l.id,
    name: l.name,
    builtIn: false,
    createdBy: l.created_by,
    words: wordRows
      .filter((w) => w.list_id === l.id)
      .sort((a, b) => a.position - b.position)
      .map((w) => ({ id: w.id, hanzi: w.hanzi, pinyin: w.pinyin, meaning: w.meaning })),
  }));
}

async function pushPending() {
  const p = await readJson(pendingKey(), emptyPending());
  const results = Object.entries(p.results);
  if (results.length) {
    await api.put('/me/results', results.map(([question_id, r]) => ({ question_id, ...r })));
    await updatePending((x) => {
      for (const [id, r] of results) if (x.results[id]?.updated_at === r.updated_at) delete x.results[id];
    });
  }
  if (p.attempts.length) {
    await api.post('/me/attempts', p.attempts.map(attemptRow));
    await updatePending((x) => {
      x.attempts = x.attempts.slice(p.attempts.length);
    });
  }
  const vocab = Object.entries(p.vocab);
  if (vocab.length) {
    await api.put('/me/vocab-progress', vocab.map(([word_id, v]) => ({ word_id, ...v })));
    await updatePending((x) => {
      for (const [id, v] of vocab) if (x.vocab[id]?.updated_at === v.updated_at) delete x.vocab[id];
    });
  }
  await pushActivity();
}

const attemptRow = (a: Attempt) => ({
  deck_id: a.deckId,
  at: a.at,
  total: a.total,
  right_count: a.right,
  wrong_count: a.wrong,
  seconds: a.seconds,
});

async function pushActivity() {
  const p = await readJson(pendingKey(), emptyPending());
  for (const [day, n] of Object.entries(p.activity)) {
    await api.post('/me/activity', [{ day, n }]);
    await updatePending((x) => {
      const left = (x.activity[day] ?? 0) - n;
      if (left > 0) x.activity[day] = left;
      else delete x.activity[day];
    });
  }
}

const markOffline = () => set({ offline: true });

// ------------------------------------------------------------------ quiz answers

/** Saves an answer locally right away, then on the server. */
export function record(q: Question, correct: boolean) {
  const updated_at = new Date().toISOString();
  set((s) => ({ results: { ...s.results, [q.id]: correct } }));
  bumpActivity();
  saveCache();
  updatePending((p) => {
    p.results[q.id] = { correct, updated_at };
  })
    .then(() => pushPending())
    .catch(markOffline);
}

/** Saves a finished session for every deck it touched. */
export function recordAttempt(questions: Question[], right: number, wrong: number, seconds: number) {
  const ids = new Set(questions.map((q) => deckOf(q.id)?.id).filter((id): id is string => !!id));
  const at = new Date().toISOString();
  const rows: Attempt[] = [...ids].map((deckId) => ({
    deckId,
    at,
    total: questions.length,
    right,
    wrong,
    seconds,
  }));
  set((s) => ({ attempts: [...rows, ...s.attempts] }));
  saveCache();
  updatePending((p) => {
    p.attempts.push(...rows);
  })
    .then(() => pushPending())
    .catch(markOffline);
}

export async function resetProgress(questionIds: string[]) {
  await api.post('/me/results/delete', { question_ids: questionIds });
  set((s) => {
    const results = { ...s.results };
    for (const id of questionIds) delete results[id];
    return { results };
  });
  await updatePending((p) => {
    for (const id of questionIds) delete p.results[id];
  });
  saveCache();
}

const aiExplanations = new Map<string, Promise<string>>();

/** AI explanation of why option `chosen` of `q` is wrong (the server caches it too). */
export function explainWrong(q: Question, chosen: number): Promise<string> {
  const key = `${q.id}#${chosen}`;
  let p = aiExplanations.get(key);
  if (!p) {
    p = api.post<{ text: string }>('/ai/explain', { question_id: q.id, chosen }).then((r) => r.text);
    p.catch(() => aiExplanations.delete(key)); // let the learner retry
    aiExplanations.set(key, p);
  }
  return p;
}

export function deckOf(questionId: string): Deck | undefined {
  return get().decks.find((d) => d.sections.some((s) => s.questions.some((q) => q.id === questionId)));
}

export function sectionOf(questionId: string): string {
  for (const d of get().decks) for (const s of d.sections) if (s.questions.some((q) => q.id === questionId)) return s.title;
  return '';
}

// ------------------------------------------------------------------ vocabulary

export const progressOf = (progress: Record<string, WordProgress>, w: VocabWord): WordProgress =>
  progress[w.id] ?? { known: false, correct: 0, wrong: 0 };

function saveWord(w: VocabWord, next: WordProgress) {
  const updated_at = new Date().toISOString();
  set((s) => ({ vocabProgress: { ...s.vocabProgress, [w.id]: next } }));
  bumpActivity();
  saveCache();
  updatePending((p) => {
    p.vocab[w.id] = { ...next, updated_at };
  })
    .then(() => pushPending())
    .catch(markOffline);
}

/** Flashcard: "Đã thuộc" / "Chưa thuộc". */
export function setKnown(w: VocabWord, known: boolean) {
  const p = progressOf(get().vocabProgress, w);
  saveWord(w, { ...p, known });
}

/** Quiz answer; two right answers mark the word known, a wrong one unmarks it. */
export function recordAnswer(w: VocabWord, correct: boolean) {
  const p = progressOf(get().vocabProgress, w);
  saveWord(w, {
    known: correct ? p.known || p.correct + 1 >= 2 : false,
    correct: p.correct + (correct ? 1 : 0),
    wrong: p.wrong + (correct ? 0 : 1),
  });
}

/** HSK lists first, then the lists imported by admins. */
export const chineseLists = (custom: VocabList[]) => [...hskLists, ...custom];

export const knownIn = (progress: Record<string, WordProgress>, words: VocabWord[]) =>
  words.filter((w) => progress[w.id]?.known).length;

/** Unknown words first (shuffled), then known ones. */
export function studyOrder(progress: Record<string, WordProgress>, words: VocabWord[]): VocabWord[] {
  const shuffled = [...words].sort(() => Math.random() - 0.5);
  return [...shuffled.filter((w) => !progress[w.id]?.known), ...shuffled.filter((w) => progress[w.id]?.known)];
}

// ------------------------------------------------------------------ daily activity

export const dayKey = (d: Date) =>
  `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')}`;

/** Counts `n` answers for today. */
export function bumpActivity(n = 1) {
  const today = dayKey(new Date());
  set((s) => ({ activity: { ...s.activity, [today]: (s.activity[today] ?? 0) + n } }));
  updatePending((p) => {
    p.activity[today] = (p.activity[today] ?? 0) + n;
  })
    .then(() => pushActivity())
    .catch(() => {});
}

/** Consecutive days with at least one answer, ending today (or yesterday). */
export function streakOf(activity: Record<string, number>): number {
  const day = new Date();
  if (!activity[dayKey(day)]) day.setDate(day.getDate() - 1);
  let n = 0;
  while (activity[dayKey(day)]) {
    n++;
    day.setDate(day.getDate() - 1);
  }
  return n;
}

export function setDailyGoal(goal: number) {
  set({ dailyGoal: goal });
  AsyncStorage.setItem('daily_goal', String(goal)).catch(() => {});
}

// ------------------------------------------------------------------ profile photo

/** Uploads a new profile photo (a local JPEG uri); null removes it. */
export async function setAvatar(uri: string | null) {
  if (uri) await api.putFile('/me/avatar', uri, 'image/jpeg');
  else await api.delete('/me/avatar');
  const profile = await loadProfile();
  if (profile) set({ profile });
}

// ------------------------------------------------------------------ stats

export type Stats = { total: number; done: number; right: number; wrong: number; accuracy: number };

export function statsOf(results: Record<string, boolean>, qs: Question[]): Stats {
  let done = 0;
  let right = 0;
  for (const q of qs) {
    const r = results[q.id];
    if (r === undefined) continue;
    done++;
    if (r) right++;
  }
  return { total: qs.length, done, right, wrong: done - right, accuracy: done ? right / done : 0 };
}
