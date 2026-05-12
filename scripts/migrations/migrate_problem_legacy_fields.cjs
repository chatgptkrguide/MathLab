/**
 * Firestore migration — problem_model 의 레거시 단수 필드 정리.
 *
 * Background:
 *   클라이언트 ProblemModel 은 hint/imageUrl (단수) → hints/imageUrls (복수)
 *   로 마이그레이션됐고, fromJson 이 레거시 단수 키를 자동 흡수한다 (commit 794f497).
 *   Firestore 에 저장된 기존 문서들은 단수 키가 그대로 남아 있을 수 있으므로,
 *   본 스크립트로 다음을 일괄 처리:
 *     1. hint (string) 가 있고 hints (array) 가 비어 있거나 없으면 → hints 에 [hint] 추가.
 *     2. imageUrl (string) 이 있고 imageUrls (array) 가 비어 있거나 없으면 → imageUrls 에 [imageUrl] 추가.
 *     3. 단수 hint, imageUrl 필드는 FieldValue.delete() 로 제거.
 *
 * Usage:
 *   dry-run (변경 없이 영향 범위만 출력):
 *     NODE_PATH=functions/node_modules \
 *       node scripts/migrations/migrate_problem_legacy_fields.cjs
 *
 *   실제 실행:
 *     NODE_PATH=functions/node_modules \
 *       node scripts/migrations/migrate_problem_legacy_fields.cjs --commit
 *
 * Auth: gcloud Application Default Credentials (chatgptkrguide@gmail.com Owner).
 *       별도 SA 키 불필요.
 */

const admin = require('firebase-admin');

const COMMIT = process.argv.includes('--commit');
const PROJECT_ID = 'mathlab-gomath';

admin.initializeApp({ projectId: PROJECT_ID });
const db = admin.firestore();

async function main() {
  const mode = COMMIT ? 'COMMIT' : 'DRY-RUN';
  console.log(`\n[problem-legacy-migration] mode=${mode} project=${PROJECT_ID}\n`);

  const snapshot = await db.collection('problems').get();
  console.log(`Found ${snapshot.size} problem documents.\n`);

  let affected = 0;
  let writes = 0;
  const batches = [];
  let current = db.batch();
  let inBatch = 0;

  for (const doc of snapshot.docs) {
    const data = doc.data();
    const updates = {};

    const legacyHint = typeof data.hint === 'string' ? data.hint : null;
    const hintsArr = Array.isArray(data.hints) ? data.hints : null;
    if (legacyHint && legacyHint.length > 0 && (!hintsArr || hintsArr.length === 0)) {
      updates.hints = [legacyHint];
    }
    if (data.hint !== undefined) {
      updates.hint = admin.firestore.FieldValue.delete();
    }

    const legacyImageUrl = typeof data.imageUrl === 'string' ? data.imageUrl : null;
    const imageUrlsArr = Array.isArray(data.imageUrls) ? data.imageUrls : null;
    if (legacyImageUrl && legacyImageUrl.length > 0 &&
        (!imageUrlsArr || imageUrlsArr.length === 0)) {
      updates.imageUrls = [legacyImageUrl];
    }
    if (data.imageUrl !== undefined) {
      updates.imageUrl = admin.firestore.FieldValue.delete();
    }

    if (Object.keys(updates).length === 0) continue;
    affected++;

    const changeSummary = Object.entries(updates)
      .map(([k, v]) => {
        if (v && v._methodName === 'FieldValue.delete') return `${k}=DELETE`;
        if (Array.isArray(v)) return `${k}=[${v.length} items]`;
        return `${k}=${typeof v}`;
      })
      .join(', ');
    console.log(`  ${doc.id}: ${changeSummary}`);

    if (COMMIT) {
      current.update(doc.ref, updates);
      writes++;
      inBatch++;
      if (inBatch >= 400) {
        batches.push(current.commit());
        current = db.batch();
        inBatch = 0;
      }
    }
  }

  if (COMMIT && inBatch > 0) {
    batches.push(current.commit());
  }

  if (COMMIT) {
    await Promise.all(batches);
  }

  console.log(`\n[done] affected=${affected} writes=${COMMIT ? writes : 0} mode=${mode}`);
  if (!COMMIT && affected > 0) {
    console.log('Run again with --commit to apply changes.');
  }
}

main().catch((err) => {
  console.error('Migration failed:', err);
  process.exit(1);
});
