// GoTattoo · Edge Function — stripe-setup-intent
// Returns the data the Payment Sheet needs to SAVE a card (no charge):
// the customer, an ephemeral key, and a SetupIntent client secret.
//
// Self-contained (no ../_shared import) so it deploys from the Dashboard editor.

import Stripe from "https://esm.sh/stripe@17.5.0?target=deno";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const stripe = new Stripe(Deno.env.get("STRIPE_SECRET_KEY") ?? "", {
  apiVersion: "2024-12-18.acacia",
  httpClient: Stripe.createFetchHttpClient(),
});
const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SERVICE_ROLE = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const ANON = Deno.env.get("SUPABASE_ANON_KEY")!;
const cors = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

async function callerId(req: Request): Promise<string | null> {
  const auth = req.headers.get("Authorization");
  if (!auth) return null;
  const c = createClient(SUPABASE_URL, ANON, {
    global: { headers: { Authorization: auth } },
  });
  const { data } = await c.auth.getUser();
  return data.user?.id ?? null;
}

async function getOrCreateCustomer(userId: string): Promise<string> {
  const db = createClient(SUPABASE_URL, SERVICE_ROLE);
  const { data: profile } = await db
    .from("profiles")
    .select("stripe_customer_id, name")
    .eq("id", userId)
    .single();
  if (profile?.stripe_customer_id) return profile.stripe_customer_id as string;

  const customer = await stripe.customers.create({
    name: (profile?.name as string) ?? undefined,
    metadata: { user_id: userId },
  });
  await db
    .from("profiles")
    .update({ stripe_customer_id: customer.id })
    .eq("id", userId);
  return customer.id;
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: cors });
  const headers = { ...cors, "Content-Type": "application/json" };
  try {
    const userId = await callerId(req);
    if (!userId) {
      return new Response(JSON.stringify({ error: "unauthenticated" }), {
        status: 401,
        headers,
      });
    }

    const customer = await getOrCreateCustomer(userId);
    const ephemeralKey = await stripe.ephemeralKeys.create(
      { customer },
      { apiVersion: "2024-12-18.acacia" },
    );
    const setupIntent = await stripe.setupIntents.create({
      customer,
      usage: "off_session",
    });

    return new Response(
      JSON.stringify({
        customer,
        ephemeralKey: ephemeralKey.secret,
        setupIntent: setupIntent.client_secret,
      }),
      { headers },
    );
  } catch (err) {
    return new Response(JSON.stringify({ error: String(err) }), {
      status: 500,
      headers,
    });
  }
});
