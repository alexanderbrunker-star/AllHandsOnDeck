import type { VercelRequest, VercelResponse } from '@vercel/node';

export default async function handler(req: VercelRequest, res: VercelResponse) {
  const ANON_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVkeWx6Z3hya25icWpkZ3RyZ2ljIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzgwMTgyMDgsImV4cCI6MjA5MzU5NDIwOH0.wfPlVzKcTohVWcLteMPRMzRdsfx0YFR3kh7ZR-y2pxM";

  if (req.method === 'GET') {
    const { data, error } = await fetch(
      `https://edylzgxrknbqjdgtrgic.supabase.co/rest/v1/logs?order=created_at.desc&limit=50`,
      {
        headers: {
          apikey: ANON_KEY,
          Authorization: `Bearer ${ANON_KEY}`,
        },
      }
    ).then(r => r.json());

    if (error) {
      res.status(500).json({ error });
    } else {
      res.status(200).json(data);
    }
    return;
  }

  res.status(405).json({ error: 'GET only' });
}
