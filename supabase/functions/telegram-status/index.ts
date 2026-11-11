import { isResponse, json } from '../_shared/http.ts';
import { guard } from '../_shared/limits.ts';
import { serviceClient } from '../_shared/telegram.ts';

const CHAT_ID = /^-?\d{1,20}$/;

Deno.serve(async (req) => {
  const gate = await guard(req, 'telegram-status');
  if (isResponse(gate)) return gate;

  const admin = serviceClient();
  if (!admin) return json({ error: 'misconfigured' }, 500);

  const { data, error } = await admin
    .from('profiles')
    .select('telegram_chat_id')
    .eq('id', gate.userId)
    .maybeSingle();
  if (error) return json({ error: 'unavailable' }, 503);

  const chatId = data?.telegram_chat_id;
  if (typeof chatId === 'string' && CHAT_ID.test(chatId)) {
    return json({ linked: true, chatId });
  }
  return json({ linked: false });
});
