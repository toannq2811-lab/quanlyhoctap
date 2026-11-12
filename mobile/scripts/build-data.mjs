// Copies the shared vocabulary (../shared/assets) into src/data as JSON the app can import.
// Run after editing the TSV/JSON files: npm run data
import { readFileSync, writeFileSync } from 'node:fs';

const shared = new URL('../../shared/assets/', import.meta.url);
const out = new URL('../src/data/', import.meta.url);

// HSK 5 first: it is the level being studied now; 1–2 stay for review.
const hsk = [['hsk5', 'HSK 5'], ['hsk1', 'HSK 1'], ['hsk2', 'HSK 2']].map(([id, name]) => ({
  id,
  name,
  words: readFileSync(new URL(`chinese/${id}.tsv`, shared), 'utf8')
    .split(/\r?\n/)
    .map((line) => line.split('\t'))
    .filter((f) => f.length >= 3)
    .map(([h, p, m]) => ({ id: `${id}-${h}`, h, p, m })),
}));
writeFileSync(new URL('hsk.json', out), JSON.stringify(hsk));

for (const f of ['tenses.json', 'vocab.json']) {
  const data = JSON.parse(readFileSync(new URL(`english/${f}`, shared), 'utf8'));
  writeFileSync(new URL(`english-${f}`, out), JSON.stringify(data));
}
console.log('hsk words:', hsk.map((l) => `${l.name} ${l.words.length}`).join(', '));
