import { isResponse, json } from '../_shared/http.ts';
import { guard } from '../_shared/limits.ts';
import { botLink, randomLinkCode, serviceClient } from '../_shared/telegram.ts';

const USERNAME = /^[A-Za-z][A-Za-z0-9_]{3,31}$/;
const TEN_MINUTES_MS = 10 * 60 * 1000;

Deno.serve(async (req) => {
  const gate = await guard(req, 'telegram-link');
  if (isResponse(gate)) return gate;

  const username = Deno.env.get('TELEGRAM_BOT_USERNAME')?.replace(/^@/, '') ?? '';
  if (!USERNAME.test(username)) return json({ error: 'misconfigured' }, 500);

  const admin = serviceClient();
  if (!admin) return json({ error: 'misconfigured' }, 500);

  await admin
    .from('telegram_link_codes')
    .delete()
    .eq('user_id', gate.userId)
    .is('used_at', null);

  const expiresAt = new Date(Date.now() + TEN_MINUTES_MS).toISOString();
  let code = '';
  for (let attempt = 0; attempt < 3; attempt++) {
    code = randomLinkCode();
    const { error } = await admin.from('telegram_link_codes').insert({
      code,
      user_id: gate.userId,
      expires_at: expiresAt,
    });
    if (!error) {
      return json({
        code,
        url: botLink(username, code),
        expiresAt,
      });
    }
  }
  return json({ error: 'unavailable' }, 503);
});
