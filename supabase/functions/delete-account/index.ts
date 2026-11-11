import { isResponse, json } from '../_shared/http.ts';
import { guard } from '../_shared/limits.ts';
import { serviceClient } from '../_shared/telegram.ts';

/// Hisobni o‘chiradi: auth foydalanuvchi, profil (cascade) va telegram kodlari.
Deno.serve(async (req) => {
  const gate = await guard(req, 'delete-account');
  if (isResponse(gate)) return gate;

  const admin = serviceClient();
  if (!admin) return json({ error: 'misconfigured' }, 500);

  await admin.from('edge_rate_limits').delete().eq('user_id', gate.userId);
  await admin.from('telegram_link_codes').delete().eq('user_id', gate.userId);

  const { error } = await admin.auth.admin.deleteUser(gate.userId);
  if (error) return json({ error: 'unavailable' }, 503);
  return json({ ok: true });
});
