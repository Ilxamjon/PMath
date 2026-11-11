import { geminiGenerate } from '../_shared/gemini.ts';
import { isResponse, json, readBody } from '../_shared/http.ts';
import { guard } from '../_shared/limits.ts';

const MAX_IMAGE_CHARS = 1_500_000;
const ALLOWED_MIME = new Set(['image/jpeg', 'image/png', 'image/webp']);

const SYSTEM = `Sen PMath ko‘rish yordamchisisan.
Daftar rasmidagi qo‘lyozma matematik yechimni qadamlarga ajrat.
Faqat JSON qaytar:
{"rawText":"...","confidence":0.0,"steps":[{"index":1,"text":"...","latex":"..."}]}
index 1 dan ketma-ket. latex ixtiyoriy.
Qadamni o‘quvchi yozganidek ko‘chir. Yangi yechim o‘ylab topma.
Rasmni saqlama va javobga rasmni qaytarma.`;

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

function validateSteps(raw: unknown): Array<Record<string, unknown>> | null {
  if (!Array.isArray(raw) || raw.length === 0 || raw.length > 12) return null;
  const steps: Array<Record<string, unknown>> = [];
  for (let i = 0; i < raw.length; i++) {
    const item = raw[i];
    if (!item || typeof item !== 'object' || Array.isArray(item)) return null;
    const row = item as Record<string, unknown>;
    if (row.index !== i + 1) return null;
    if (typeof row.text !== 'string' || row.text.trim().length === 0 || row.text.trim().length > 300) {
      return null;
    }
    if (row.latex != null && (typeof row.latex !== 'string' || row.latex.length > 300)) {
      return null;
    }
    const step: Record<string, unknown> = {
      index: i + 1,
      text: row.text.trim(),
    };
    if (typeof row.latex === 'string' && row.latex.trim().length > 0) {
      step.latex = row.latex.trim();
    }
    steps.push(step);
  }
  return steps;
}

function readConfidence(value: unknown): number | null {
  if (typeof value !== 'number' || Number.isNaN(value) || value < 0 || value > 1) {
    return null;
  }
  return value;
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

  const ask = async (): Promise<Record<string, unknown> | null> => {
    const raw = await geminiGenerate(
      [
        { text: `Vazifa: ${title}. Rasmdagi qadamlarni JSON qilib qaytar.` },
        { inlineData: { mimeType, data: imageBase64 } },
      ],
      SYSTEM,
      800,
    );
    if (!raw) return null;
    const parsed = parseModelJson(raw);
    const steps = validateSteps(parsed?.steps);
    const confidence = readConfidence(parsed?.confidence);
    if (!parsed || !steps || confidence == null) return null;
    const rawText = typeof parsed.rawText === 'string'
      ? parsed.rawText.trim().slice(0, 2000)
      : steps.map((step) => step.text).join('\n');
    return {
      rawText,
      steps,
      confidence,
      modelName: Deno.env.get('GEMINI_MODEL') ?? 'gemini-2.0-flash',
    };
  };

  try {
    const first = await ask();
    const payload = first ?? await ask();
    if (!payload) return json({ error: 'invalid_schema' }, 422);
    return json(payload);
  } catch {
    return json({ error: 'upstream' }, 502);
  }
});
