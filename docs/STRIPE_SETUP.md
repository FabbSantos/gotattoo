# Stripe payments (Fase 1, test mode) — passo a passo

Fase 1: o cliente **salva o cartão** ao agendar (sem cobrança), o tatuador **aprova**
e a cobrança acontece **off-session**, com a grana retida na **plataforma**. Estorno
no cancelar/recusar. Repasse ao tatuador (Connect) é a fase 2.

Como no FCM, tudo é **dormente**: sem a chave o app builda e roda com o escrow
simulado. Estes passos ligam o pagamento real (sandbox).

## 1. Pegar as chaves de teste
Dashboard da Stripe → **Developers → API keys** (modo **Test**):
- **Publishable key** (`pk_test_...`) → vai no app via `--dart-define`.
- **Secret key** (`sk_test_...`) → vira secret das Edge Functions (NUNCA no app).

## 2. Rodar a migration
No SQL Editor do Supabase: `supabase/migrations/0011_stripe_payments.sql`.

## 3. Publicar as Edge Functions + secret
No Supabase Dashboard → **Edge Functions**, crie/deploy estas 4 (cada uma é
**self-contained** — é só colar o conteúdo do `index.ts` no editor web):
- `stripe-setup-intent`
- `stripe-charge-booking`   (cobra + notifica o cliente)
- `stripe-refund-booking`   (estorna + notifica o cliente)
- `stripe-payment-methods`  (lista/remove cartões salvos)

> As notificações de cobrança/estorno reusam a tabela `notifications` + o webhook
> `send-push`, então o push do FCM já funciona pra elas (se o FCM estiver ligado).

Secret (Project Settings → Edge Functions → Secrets):
- `STRIPE_SECRET_KEY` = `sk_test_...`
(`SUPABASE_URL`, `SUPABASE_ANON_KEY` e `SUPABASE_SERVICE_ROLE_KEY` já existem no ambiente.)

> Se for criar pela CLI: `supabase functions deploy stripe-setup-intent` (idem as outras)
> e `supabase secrets set STRIPE_SECRET_KEY=sk_test_...`.

## 4. Buildar com a publishable key
```bash
flutter build apk --release \
  --dart-define=SUPABASE_URL=https://uonpcpeqjrqhrplgaqbi.supabase.co \
  --dart-define=SUPABASE_KEY=sb_publishable_... \
  --dart-define=STRIPE_PUBLISHABLE_KEY=pk_test_...
```

## 5. Testar (cartões de teste)
1. Como **cliente**, agende uma tatuagem → aparece o Payment Sheet pra salvar o cartão.
   Use `4242 4242 4242 4242`, validade futura, CVC qualquer.
2. Aprove pelo lado **tatuador** (ou via SQL: `update bookings set status='confirmed'...`
   **NÃO** dispara a cobrança — a cobrança vem do botão Aprovar no app, que chama a
   function). Pra cobrar de verdade, aprove pelo app.
3. Veja o pagamento em **Stripe Dashboard → Payments** (test mode).
4. Cancele/recuse um agendamento pago → confere o **Refund** no dashboard.

Cartões úteis (test mode):
- `4242 4242 4242 4242` — sucesso.
- `4000 0000 0000 9995` — recusado por fundos insuficientes (testa o caminho de falha).

> iOS precisa de config extra (merchant id Apple Pay opcional). Fora de escopo (Android).
