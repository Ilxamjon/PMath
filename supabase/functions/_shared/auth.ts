import { createClient } from 'npm:@supabase/supabase-js@2';

import { json } from './http.ts';

/// Foydalanuvchi JWT sini tekshiradi. Anon kalit yoki bo‘sh token rad etiladi.
export async function requireUser(
  req: Request,
): Promise<{ userId: string } | Response> {
  const header = req.headers.get('Authorization') ?? '';
  const token = header.startsWith('Bearer ') ? header.slice(7).trim() : '';
  if (!token) return json({ error: 'unauthorized' }, 401);

  const url = Deno.env.get('SUPABASE_URL');
  const anonKey = Deno.env.get('SUPABASE_ANON_KEY');
  if (!url || !anonKey) return json({ error: 'misconfigured' }, 500);

  const supabase = createClient(url, anonKey, {
    global: { headers: { Authorization: `Bearer ${token}` } },
    auth: { persistSession: false, autoRefreshToken: false },
  });

  const { data, error } = await supabase.auth.getUser(token);
  if (error || !data.user?.id) return json({ error: 'unauthorized' }, 401);
  return { userId: data.user.id };
}
