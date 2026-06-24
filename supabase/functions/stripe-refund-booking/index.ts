// GoTattoo · Edge Function — stripe-refund-booking
// Called on cancel/reject of a charged booking. Refunds the PaymentIntent.
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
        "id, artist_id, client_id, price, product_name, payment_intent_id, payment_status",
      )
      .eq("id", booking_id)
      .single();

    if (!booking) return json({ ok: false, error: "booking not found" }, 404);
    // Either party of the booking may trigger a refund (on cancel/reject).
    if (booking.artist_id !== userId && booking.client_id !== userId) {
      return json({ ok: false, error: "not your booking" }, 403);
    }
    if (booking.payment_status !== "paid" || !booking.payment_intent_id) {
      return json({ ok: true, nothing: true }); // nothing to refund
    }

    await stripe.refunds.create({
      payment_intent: booking.payment_intent_id as string,
    });
    await db
      .from("bookings")
      .update({ payment_status: "refunded" })
      .eq("id", booking.id);

    // Notify the client that the money is on the way back.
    const amount = Number(booking.price).toFixed(2).replace(".", ",");
    const product = booking.product_name || "sua tatuagem";
    await db.from("notifications").insert({
      user_id: booking.client_id,
      type: "payment_refunded",
      title: "Estorno realizado",
      body: `R$ ${amount} de ${product} voltou para o seu cartão.`,
      booking_id: booking.id,
    });

    return json({ ok: true });
  } catch (err) {
    return json({ ok: false, error: String(err) }, 500);
  }
});
