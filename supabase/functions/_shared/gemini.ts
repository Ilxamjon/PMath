const FINAL_ANSWER = /(javob|natija|yechim)\s*[:=\-]\s*[-+]?\d/i;
const MAX_REPLY = 600;

export function isSafeCoachReply(reply: string): boolean {
  const text = reply.trim();
  if (!text || text.length > MAX_REPLY) return false;
  if (FINAL_ANSWER.test(text)) return false;
  return true;
}

type GeminiPart = {
  text?: string;
  inlineData?: { mimeType: string; data: string };
};

/// Kalit faqat muhitdan olinadi va javob tanasiga yozilmaydi.
export async function geminiGenerate(
  parts: GeminiPart[],
  system: string,
  maxOutputTokens: number,
): Promise<string | null> {
  const apiKey = Deno.env.get('GEMINI_API_KEY');
  if (!apiKey) return null;

  const model = Deno.env.get('GEMINI_MODEL') ?? 'gemini-2.0-flash';
  const url =
    `https://generativelanguage.googleapis.com/v1beta/models/${model}:generateContent`;

  const res = await fetch(url, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'x-goog-api-key': apiKey,
    },
    body: JSON.stringify({
      systemInstruction: { parts: [{ text: system }] },
      contents: [{ role: 'user', parts }],
      generationConfig: { temperature: 0.4, maxOutputTokens },
    }),
  });

  if (!res.ok) return null;
  const data = await res.json();
  const text = data?.candidates?.[0]?.content?.parts?.[0]?.text;
  return typeof text === 'string' ? text : null;
}
