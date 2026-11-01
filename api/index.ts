/**
 * VERCEL ENTRY POINT
 * ----------------------------------------------------------------------------
 * On Vercel there is no always-running server. Instead, every request to /api/...
 * (see the "rewrites" in vercel.json) starts this small "serverless function",
 * which hands the request to the same Express app defined in server.ts.
 * `appPromise` waits until the app has connected to MySQL.
 */
import appPromise from '../server';

export default async function handler(req: any, res: any) {
  const app = await appPromise;
  return app(req, res);
}
