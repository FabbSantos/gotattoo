// GoTattoo · Edge Function — stripe-payment-methods
// Lists the caller's saved cards, or detaches one.
//   body (none) or { action: "list" }            -> { cards: [...] }
//   body { action: "detach", payment_method_id }  -> { ok: true }
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

async function customerFor(userId: string): Promise<string | null> {
  const db = createClient(SUPABASE_URL, SERVICE_ROLE);
  const { data } = await db
    .from("profiles")
    .select("stripe_customer_id")
    .eq("id", userId)
    .single();
  return (data?.stripe_customer_id as string) ?? null;
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: cors });
  const json = (body: unknown, status = 200) =>
    new Response(JSON.stringify(body), {
      status,
      headers: { ...cors, "Content-Type": "application/json" },
    });

  try {
    const userId = await callerId(req);
    if (!userId) return json({ ok: false, error: "unauthenticated" }, 401);

    const customer = await customerFor(userId);
    if (!customer) return json({ cards: [] });

    let action = "list";
    let pmId: string | undefined;
    try {
      const body = await req.json();
      action = body.action ?? "list";
      pmId = body.payment_method_id;
    } catch (_) {
      // no body -> list
    }

    if (action === "detach") {
      if (!pmId) return json({ ok: false, error: "missing id" }, 400);
      // Make sure the card belongs to this caller before detaching.
      const pm = await stripe.paymentMethods.retrieve(pmId);
      if (pm.customer !== customer) {
        return json({ ok: false, error: "not your card" }, 403);
      }
      await stripe.paymentMethods.detach(pmId);
      return json({ ok: true });
    }

    const methods = await stripe.paymentMethods.list({
      customer,
      type: "card",
    });
    const cards = methods.data.map((m) => ({
      id: m.id,
      brand: m.card?.brand ?? "card",
      last4: m.card?.last4 ?? "????",
      exp_month: m.card?.exp_month ?? 0,
      exp_year: m.card?.exp_year ?? 0,
    }));
    return json({ cards });
  } catch (err) {
    return json({ ok: false, error: String(err) }, 500);
  }
});
