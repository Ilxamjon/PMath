import { json } from '../_shared/http.ts';
import { enforceRateLimit } from '../_shared/limits.ts';
import {
  messageForClaim,
  parseStart,
  secretsMatch,
  serviceClient,
  telegramMessages,
} from '../_shared/telegram.ts';

const WEBHOOK_ACTOR = '00000000-0000-4000-8000-000000000001';

Deno.serve(async (req) => {
  if (req.method !== 'POST') return json({ error: 'method_not_allowed' }, 405);

  const expected = Deno.env.get('TELEGRAM_WEBHOOK_SECRET') ?? '';
  const got = req.headers.get('X-Telegram-Bot-Api-Secret-Token') ?? '';
  if (!secretsMatch(expected, got)) return json({ error: 'unauthorized' }, 401);

  const limited = await enforceRateLimit(WEBHOOK_ACTOR, 'telegram-webhook');
  if (limited) return limited;

  const token = Deno.env.get('TELEGRAM_BOT_TOKEN');
  const admin = serviceClient();
  if (!token || !admin) return json({ error: 'misconfigured' }, 500);

  let update: Record<string, unknown>;
  try {
    const text = await req.text();
    if (text.length > 16384) return json({ error: 'payload_too_large' }, 413);
    const parsed = JSON.parse(text);
    if (parsed === null || typeof parsed !== 'object' || Array.isArray(parsed)) {
      return json({ ok: true });
    }
    update = parsed as Record<string, unknown>;
  } catch {
    return json({ ok: true });
  }

  const message = update.message;
  if (message === null || typeof message !== 'object' || Array.isArray(message)) {
    return json({ ok: true });
  }
  const record = message as Record<string, unknown>;
  const chat = record.chat;
  const chatId = chat && typeof chat === 'object'
    ? (chat as Record<string, unknown>).id
    : null;
  const text = typeof record.text === 'string' ? record.text : undefined;
  const parsed = parseStart(text);
  if (parsed.kind === 'ignore') return json({ ok: true });

  const id = typeof chatId === 'number' || typeof chatId === 'string'
    ? String(chatId)
    : '';
  if (!/^-?\d{1,20}$/.test(id)) return json({ ok: true });

  let reply = telegramMessages.badCode;
  if (parsed.kind === 'no_code') {
    reply = telegramMessages.noCode;
  } else if (parsed.kind === 'code') {
    const { data, error } = await admin.rpc('claim_telegram_link', {
      p_code: parsed.code,
      p_chat_id: id,
    });
    reply = error || typeof data !== 'string'
      ? telegramMessages.notFound
      : messageForClaim(data);
  }

  await sendReply(token, id, reply);
  return json({ ok: true });
});

async function sendReply(token: string, chatId: string, text: string) {
  try {
    await fetch(`https://api.telegram.org/bot${token}/sendMessage`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ chat_id: chatId, text }),
    });
  } catch {
    // Javob ketmasa ham kod allaqachon yozilgan bo‘lishi mumkin.
  }
}
