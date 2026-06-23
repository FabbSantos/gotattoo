// GoTattoo · Edge Function — send-push
//
// Invoked by a Supabase Database Webhook on INSERT into public.notifications.
// Looks up the recipient's FCM device tokens and delivers the push via the
// Firebase Cloud Messaging HTTP v1 API.
//
// Required secrets (supabase secrets set ...):
//   FCM_PROJECT_ID     – Firebase project id
//   FCM_CLIENT_EMAIL   – service account client_email
//   FCM_PRIVATE_KEY    – service account private_key (PEM, keep the \n escapes)
//   SUPABASE_URL / SUPABASE_SERVICE_ROLE_KEY are provided by the platform.

import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { create, getNumericDate } from "https://deno.land/x/djwt@v3.0.2/mod.ts";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SERVICE_ROLE = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const FCM_PROJECT_ID = Deno.env.get("FCM_PROJECT_ID")!;
const FCM_CLIENT_EMAIL = Deno.env.get("FCM_CLIENT_EMAIL")!;
const FCM_PRIVATE_KEY = (Deno.env.get("FCM_PRIVATE_KEY") ?? "").replace(/\\n/g, "\n");

function pemToDer(pem: string): ArrayBuffer {
  const b64 = pem
    .replace(/-----BEGIN PRIVATE KEY-----/, "")
    .replace(/-----END PRIVATE KEY-----/, "")
    .replace(/\s+/g, "");
  const bin = atob(b64);
  const bytes = new Uint8Array(bin.length);
  for (let i = 0; i < bin.length; i++) bytes[i] = bin.charCodeAt(i);
  return bytes.buffer;
}

/** Mint a short-lived Google OAuth access token for FCM from the service account. */
async function getAccessToken(): Promise<string> {
  const key = await crypto.subtle.importKey(
    "pkcs8",
    pemToDer(FCM_PRIVATE_KEY),
    { name: "RSASSA-PKCS1-v1_5", hash: "SHA-256" },
    false,
    ["sign"],
  );
  const jwt = await create(
    { alg: "RS256", typ: "JWT" },
    {
      iss: FCM_CLIENT_EMAIL,
      scope: "https://www.googleapis.com/auth/firebase.messaging",
      aud: "https://oauth2.googleapis.com/token",
      iat: getNumericDate(0),
      exp: getNumericDate(3600),
    },
    key,
  );

  const res = await fetch("https://oauth2.googleapis.com/token", {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: new URLSearchParams({
      grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer",
      assertion: jwt,
    }),
  });
  const json = await res.json();
  if (!json.access_token) {
    throw new Error(`OAuth failed: ${JSON.stringify(json)}`);
  }
  return json.access_token as string;
}

Deno.serve(async (req) => {
  try {
    const payload = await req.json();
    // Database Webhook puts the new row in `.record`; allow a raw row too.
    const record = payload.record ?? payload;
    const userId = record.user_id as string | undefined;
    const title = (record.title as string) ?? "GoTattoo";
    const body = (record.body as string) ?? "";

    if (!userId) return new Response("no user", { status: 200 });

    const supabase = createClient(SUPABASE_URL, SERVICE_ROLE);
    const { data: tokens } = await supabase
      .from("device_tokens")
      .select("token")
      .eq("user_id", userId);

    if (!tokens || tokens.length === 0) {
      return new Response("no tokens", { status: 200 });
    }

    const accessToken = await getAccessToken();

    for (const { token } of tokens) {
      const res = await fetch(
        `https://fcm.googleapis.com/v1/projects/${FCM_PROJECT_ID}/messages:send`,
        {
          method: "POST",
          headers: {
            Authorization: `Bearer ${accessToken}`,
            "Content-Type": "application/json",
          },
          body: JSON.stringify({
            message: {
              token,
              notification: { title, body },
              android: { priority: "HIGH" },
            },
          }),
        },
      );

      // Prune tokens FCM no longer recognises.
      if (res.status === 404 || res.status === 400) {
        await supabase.from("device_tokens").delete().eq("token", token);
      }
    }

    return new Response("ok", { status: 200 });
  } catch (err) {
    return new Response(`error: ${err}`, { status: 500 });
  }
});
