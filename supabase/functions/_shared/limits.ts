import { createClient } from 'npm:@supabase/supabase-js@2';

import { requireUser } from './auth.ts';
import { isResponse, json, preflight } from './http.ts';

const WINDOW_MS = 60_000;

export const RATE_LIMITS = {
  'ai-coach': 20,
  'telegram-notify': 10,
  'vision-analyze': 6,
} as const;

export type FunctionName = keyof typeof RATE_LIMITS;

/// Daqiqalik oyna. Jadval yo‘q bo‘lsa 503 — cheksiz chaqiruv ochilmaydi.
export async function enforceRateLimit(
  userId: string,
  fn: FunctionName,
): Promise<Response | null> {
  const url = Deno.env.get('SUPABASE_URL');
  const serviceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY');
  if (!url || !serviceKey) return json({ error: 'misconfigured' }, 500);

  const windowStart = new Date(
    Math.floor(Date.now() / WINDOW_MS) * WINDOW_MS,
  ).toISOString();

  const supabase = createClient(url, serviceKey, {
    auth: { persistSession: false, autoRefreshToken: false },
  });

  const { data, error } = await supabase.rpc('bump_edge_rate_limit', {
    p_user_id: userId,
    p_fn: fn,
    p_window: windowStart,
    p_limit: RATE_LIMITS[fn],
  });

  if (error || typeof data !== 'number') {
    return json({ error: 'rate_limit_unavailable' }, 503);
  }
  if (data < 0) return json({ error: 'rate_limited' }, 429);
  return null;
}

/// CORS, POST, JWT va tezlik chegarasi.
export async function guard(
  req: Request,
  fn: FunctionName,
): Promise<{ userId: string } | Response> {
  const origin = preflight(req);
  if (origin) return origin;
  if (req.method !== 'POST') return json({ error: 'method_not_allowed' }, 405);

  const user = await requireUser(req);
  if (isResponse(user)) return user;

  const limited = await enforceRateLimit(user.userId, fn);
  if (limited) return limited;
  return user;
}
