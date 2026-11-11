export const corsHeaders: Record<string, string> = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers':
    'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
};

export function json(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, 'Content-Type': 'application/json' },
  });
}

export function isResponse(value: unknown): value is Response {
  return value instanceof Response;
}

export function preflight(req: Request): Response | null {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }
  return null;
}

/// Butun tanani o‘qiydi va hajm chegarasidan oshsa 413 qaytaradi.
export async function readBody(
  req: Request,
  maxChars: number,
): Promise<Record<string, unknown> | Response> {
  const declared = Number(req.headers.get('content-length') ?? '0');
  if (Number.isFinite(declared) && declared > maxChars) {
    return json({ error: 'payload_too_large' }, 413);
  }

  const text = await req.text();
  if (text.length > maxChars) {
    return json({ error: 'payload_too_large' }, 413);
  }

  try {
    const parsed = JSON.parse(text);
    if (parsed === null || typeof parsed !== 'object' || Array.isArray(parsed)) {
      return json({ error: 'invalid_body' }, 400);
    }
    return parsed as Record<string, unknown>;
  } catch {
    return json({ error: 'invalid_body' }, 400);
  }
}

export function asBoundedString(
  value: unknown,
  maxLength: number,
  { required = false }: { required?: boolean } = {},
): string | Response {
  if (value == null || value === '') {
    return required ? json({ error: 'invalid_field' }, 400) : '';
  }
  if (typeof value !== 'string') return json({ error: 'invalid_field' }, 400);
  const trimmed = value.trim();
  if (required && trimmed.length === 0) {
    return json({ error: 'invalid_field' }, 400);
  }
  if (trimmed.length > maxLength) return json({ error: 'invalid_field' }, 400);
  return trimmed;
}

/// Boshqaruv belgilari va qo‘shtirnoqlarni olib tashlaydi.
export function sanitizeText(input: string, maxLength: number): string {
  const cleaned = input
    .replace(/[\u0000-\u001F\u007F]/g, ' ')
    .replace(/"/g, "'")
    .replace(/\s+/g, ' ')
    .trim();
  if (cleaned.length <= maxLength) return cleaned;
  return cleaned.slice(0, maxLength);
}
