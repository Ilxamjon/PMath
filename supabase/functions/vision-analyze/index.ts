import { geminiGenerate } from '../_shared/gemini.ts';
import { isResponse, json, readBody } from '../_shared/http.ts';
import { guard } from '../_shared/limits.ts';

const MAX_IMAGE_CHARS = 1_500_000;
const ALLOWED_MIME = new Set(['image/jpeg', 'image/png', 'image/webp']);

const SYSTEM = `Sen PMath ko‘rish yordamchisisan.
Daftar rasmidagi yechim qadamlarini o‘zbek lotinida ajrat.
Faqat JSON qaytar: {"rawText":"...","steps":["qadam"],"confidence":0.0}
Qadamlarni o‘quvchi yozganidek ko‘chir. Yangi yechim o‘ylab topma.
Yakuniy to‘g‘ri javobni o‘zing qo‘shma.`;

function parseModelJson(text: string): Record<string, unknown> | null {
  const trimmed = text
    .trim()
    .replace(/^```json\s*/i, '')
    .replace(/^```\s*/i, '')
    .replace(/```$/i, '')
    .trim();
  const tryParse = (raw: string): Record<string, unknown> | null => {
    try {
      const value = JSON.parse(raw);
      if (value && typeof value === 'object' && !Array.isArray(value)) {
        return value as Record<string, unknown>;
      }
    } catch {
      return null;
    }
    return null;
  };

  const direct = tryParse(trimmed);
  if (direct) return direct;
  const start = trimmed.indexOf('{');
  const end = trimmed.lastIndexOf('}');
  if (start >= 0 && end > start) return tryParse(trimmed.slice(start, end + 1));
  return null;
}

Deno.serve(async (req) => {
  const gate = await guard(req, 'vision-analyze');
  if (isResponse(gate)) return gate;

  const body = await readBody(req, MAX_IMAGE_CHARS + 8192);
  if (isResponse(body)) return body;

  const imageBase64 = typeof body.imageBase64 === 'string' ? body.imageBase64.trim() : '';
  const mimeType = typeof body.mimeType === 'string' ? body.mimeType.trim() : '';
  const title = typeof body.titleUz === 'string' ? body.titleUz.trim().slice(0, 200) : '';

  if (
    imageBase64.length === 0 ||
    imageBase64.length > MAX_IMAGE_CHARS ||
    !ALLOWED_MIME.has(mimeType) ||
    title.length === 0
  ) {
    return json({ error: 'invalid_field' }, 400);
  }

  let raw: string | null = null;
  try {
    raw = await geminiGenerate(
      [
        {
          text: `Vazifa: ${title}. Rasmdagi qadamlarni JSON qilib qaytar.`,
        },
        { inlineData: { mimeType, data: imageBase64 } },
      ],
      SYSTEM,
      500,
    );
  } catch {
    return json({ error: 'upstream' }, 502);
  }

  if (!raw) return json({ error: 'upstream' }, 502);
  const parsed = parseModelJson(raw);
  const steps = Array.isArray(parsed?.steps)
    ? parsed.steps.filter((step): step is string => typeof step === 'string' && step.trim().length > 0)
        .slice(0, 12)
        .map((step) => step.trim().slice(0, 300))
    : [];
  if (!parsed || steps.length === 0) return json({ error: 'upstream' }, 502);

  const rawText = typeof parsed.rawText === 'string'
    ? parsed.rawText.trim().slice(0, 2000)
    : steps.join('\n');
  const confidenceValue = typeof parsed.confidence === 'number' ? parsed.confidence : 0.5;
  const confidence = Math.min(1, Math.max(0, confidenceValue));

  return json({
    rawText,
    steps,
    confidence,
    modelName: Deno.env.get('GEMINI_MODEL') ?? 'gemini-2.0-flash',
  });
});
