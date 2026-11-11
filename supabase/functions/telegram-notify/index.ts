import { isResponse, json, readBody } from '../_shared/http.ts';
import { guard } from '../_shared/limits.ts';

const CHAT_ID = /^-?\d{1,20}$/;

Deno.serve(async (req) => {
  const gate = await guard(req, 'telegram-notify');
  if (isResponse(gate)) return gate;

  const body = await readBody(req, 4096);
  if (isResponse(body)) return body;

  const chatId = typeof body.chatId === 'string' ? body.chatId.trim() : '';
  const text = typeof body.text === 'string' ? body.text.trim() : '';
  if (!CHAT_ID.test(chatId) || text.length === 0 || text.length > 1000) {
    return json({ error: 'invalid_field' }, 400);
  }

  const token = Deno.env.get('TELEGRAM_BOT_TOKEN');
  if (!token) return json({ error: 'misconfigured' }, 500);

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
