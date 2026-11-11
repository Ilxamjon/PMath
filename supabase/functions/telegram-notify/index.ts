import { isResponse, json, readBody } from '../_shared/http.ts';
import { guard } from '../_shared/limits.ts';
import { serviceClient } from '../_shared/telegram.ts';

const CHAT_ID = /^-?\d{1,20}$/;

Deno.serve(async (req) => {
  const gate = await guard(req, 'telegram-notify');
  if (isResponse(gate)) return gate;

  const body = await readBody(req, 4096);
  if (isResponse(body)) return body;

  const text = typeof body.text === 'string' ? body.text.trim() : '';
  if (text.length === 0 || text.length > 1000) {
    return json({ error: 'invalid_field' }, 400);
  }

  const admin = serviceClient();
  const token = Deno.env.get('TELEGRAM_BOT_TOKEN');
  if (!admin || !token) return json({ error: 'misconfigured' }, 500);

  const { data, error } = await admin
    .from('profiles')
    .select('telegram_chat_id')
    .eq('id', gate.userId)
    .maybeSingle();
  if (error) return json({ error: 'unavailable' }, 503);
  const chatId = data?.telegram_chat_id;
  if (typeof chatId !== 'string' || !CHAT_ID.test(chatId)) {
    return json({ error: 'not_linked' }, 409);
  }

  try {
    const res = await fetch(
      `https://api.telegram.org/bot${token}/sendMessage`,
      {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          chat_id: chatId,
          text,
          parse_mode: 'HTML',
        }),
      },
    );
    if (!res.ok) return json({ error: 'upstream' }, 502);
    const payload = await res.json();
    if (payload?.ok !== true) return json({ error: 'upstream' }, 502);
    return json({ ok: true });
  } catch {
    return json({ error: 'upstream' }, 502);
  }
});
