import { createClient, type SupabaseClient } from 'npm:@supabase/supabase-js@2';

export const telegramMessages = {
  linked: 'Ulandi ✅',
  used: 'Bu kod allaqachon ishlatilgan.',
  expired: 'Kod muddati tugagan. Ilovadan yangi kod oling.',
  notFound: 'Kod topilmadi. Ilovadagi “Telegramni ulash” tugmasini bosing.',
  badCode: 'Kod noto‘g‘ri. Ilovadan yangi kod oling.',
  noCode: 'Ulanish uchun ilovadagi “Telegramni ulash” tugmasini bosing.',
} as const;

const CODE = /^[ABCDEFGHJKLMNPQRSTUVWXYZ23456789]{8}$/;

export type StartParse =
  | { kind: 'ignore' }
  | { kind: 'no_code' }
  | { kind: 'bad_code' }
  | { kind: 'code'; code: string };

/// `/start KOD` yoki `/start@bot KOD`. Boshqa xabarlar e’tiborsiz.
export function parseStart(text: string | undefined): StartParse {
  if (!text) return { kind: 'ignore' };
  const trimmed = text.trim();
  if (!trimmed.startsWith('/start')) return { kind: 'ignore' };
  const match = trimmed.match(/^\/start(?:@\w+)?(?:\s+(\S+))?$/);
  if (!match) return { kind: 'bad_code' };
  if (!match[1]) return { kind: 'no_code' };
  const code = match[1].toUpperCase();
  if (!CODE.test(code)) return { kind: 'bad_code' };
  return { kind: 'code', code };
}

export function messageForClaim(result: string): string {
  switch (result) {
    case 'ok':
      return telegramMessages.linked;
    case 'used':
      return telegramMessages.used;
    case 'expired':
      return telegramMessages.expired;
    default:
      return telegramMessages.notFound;
  }
}

export function serviceClient(): SupabaseClient | null {
  const url = Deno.env.get('SUPABASE_URL');
  const key = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY');
  if (!url || !key) return null;
  return createClient(url, key, {
    auth: { persistSession: false, autoRefreshToken: false },
  });
}

/// Uzunlik farqi ham darhol qaytmaydi.
export function secretsMatch(expected: string, got: string): boolean {
  const enc = new TextEncoder();
  const a = enc.encode(expected);
  const b = enc.encode(got);
  const length = Math.max(a.length, b.length);
  let diff = a.length === b.length ? 0 : 1;
  for (let i = 0; i < length; i++) {
    diff |= (a[i] ?? 0) ^ (b[i] ?? 0);
  }
  return diff === 0 && expected.length > 0;
}

const ALPHABET = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';

export function randomLinkCode(): string {
  const bytes = new Uint8Array(8);
  crypto.getRandomValues(bytes);
  return Array.from(bytes, (b) => ALPHABET[b % ALPHABET.length]).join('');
}

export function botLink(username: string, code: string): string {
  return `https://t.me/${username}?start=${code}`;
}
