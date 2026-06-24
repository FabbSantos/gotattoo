// GoTattoo · Edge Function — stripe-charge-booking
// Called by the artist on approval. Charges the client's saved card off-session
// for the booking amount, then confirms the booking. Funds stay on the platform
// (artist payout via Connect is phase 2).
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

function admin() {
  return createClient(SUPABASE_URL, SERVICE_ROLE);
}

async function callerId(req: Request): Promise<string | null> {
  const auth = req.headers.get("Authorization");
  if (!auth) return null;
  const c = createClient(SUPABASE_URL, ANON, {
    global: { headers: { Authorization: auth } },
  });
  const { data } = await c.auth.getUser();
  return data.user?.id ?? null;
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

    const { booking_id } = await req.json();
    const db = admin();
    const { data: booking } = await db
      .from("bookings")
      .select(
        "id, artist_id, client_id, price, product_name, status, payment_status",
      )
      .eq("id", booking_id)
      .single();

    if (!booking) return json({ ok: false, error: "booking not found" }, 404);
    if (booking.artist_id !== userId) {
      return json({ ok: false, error: "not your booking" }, 403);
    }
    if (booking.payment_status === "paid") {
      return json({ ok: true, already: true });
    }

    // The client's saved card.
    const { data: profile } = await db
      .from("profiles")
      .select("stripe_customer_id")
      .eq("id", booking.client_id)
      .single();
    const customer = profile?.stripe_customer_id as string | undefined;
    if (!customer) return json({ ok: false, error: "no card on file" }, 400);

    const methods = await stripe.paymentMethods.list({
      customer,
      type: "card",
      limit: 1,
    });
    const pm = methods.data[0]?.id;
    if (!pm) return json({ ok: false, error: "no card on file" }, 400);

    let intent;
    try {
      intent = await stripe.paymentIntents.create({
        amount: Math.round(Number(booking.price) * 100),
        currency: "brl",
        customer,
        payment_method: pm,
        off_session: true,
        confirm: true,
        metadata: { booking_id: booking.id },
      });
    } catch (err) {
      // Card declined / needs authentication etc.
      await db
        .from("bookings")
        .update({ payment_status: "failed" })
        .eq("id", booking.id);
      return json({ ok: false, error: String(err) }, 402);
    }

    await db
      .from("bookings")
      .update({
        payment_intent_id: intent.id,
        payment_status: "paid",
        status: "confirmed",
      })
      .eq("id", booking.id);

    // Notify the client that the charge went through (→ send-push webhook).
    const amount = Number(booking.price).toFixed(2).replace(".", ",");
    const product = booking.product_name || "sua tatuagem";
    await db.from("notifications").insert({
      user_id: booking.client_id,
      type: "payment_charged",
      title: "Pagamento confirmado",
      body: `Cobramos R$ ${amount} de ${product} no seu cartão.`,
      booking_id: booking.id,
    });

    return json({ ok: true });
  } catch (err) {
    return json({ ok: false, error: String(err) }, 500);
  }
});
