# Push notifications (FCM) — passo a passo

O código do app e do backend já está pronto e **dormente**: sem o `google-services.json`
o app compila e roda normal (com as notificações in-app/locais). Estes passos "ligam"
o push real (app fechado/morto). Só você consegue fazê-los (precisam da sua conta Google).

## 1. Criar o projeto Firebase (só mensageria)
1. https://console.firebase.google.com → **Adicionar projeto** (pode chamar de `GoTattoo`).
   Não precisa ativar Analytics.
2. Dentro do projeto: **Adicionar app → Android**.
   - **Nome do pacote:** `com.example.gotattoo` (tem que bater com o `applicationId`).
   - Baixe o **`google-services.json`** e coloque em:
     `android/app/google-services.json`

## 2. Aplicar o plugin google-services no Gradle
> Só faça isto **depois** de colocar o `google-services.json` (senão o build quebra).

`android/settings.gradle.kts` — no bloco `plugins { ... }` adicione:
```kotlin
id("com.google.gms.google-services") version "4.4.2" apply false
```

`android/app/build.gradle.kts` — no topo, dentro de `plugins { ... }` adicione:
```kotlin
id("com.google.gms.google-services")
```

Depois: `flutter clean && flutter pub get`.

## 3. Rodar as migrations
No SQL Editor do Supabase, rode (em ordem) caso ainda não tenha:
- `supabase/migrations/0008_notifications.sql`
- `supabase/migrations/0009_device_tokens.sql`

## 4. Gerar a chave de serviço do FCM
1. Firebase Console → ⚙️ **Configurações do projeto → Contas de serviço**.
2. **Gerar nova chave privada** → baixa um JSON. Dele você usa 3 campos:
   - `project_id`  → `FCM_PROJECT_ID`
   - `client_email` → `FCM_CLIENT_EMAIL`
   - `private_key`  → `FCM_PRIVATE_KEY` (a string inteira, com os `\n`)

## 5. Publicar a Edge Function + secrets
Com a Supabase CLI (logada no projeto):
```bash
supabase functions deploy send-push
supabase secrets set FCM_PROJECT_ID="seu-project-id"
supabase secrets set FCM_CLIENT_EMAIL="...@...iam.gserviceaccount.com"
supabase secrets set FCM_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n"
```
(`SUPABASE_URL` e `SUPABASE_SERVICE_ROLE_KEY` já existem no ambiente da function.)

## 6. Criar o Database Webhook
Supabase Dashboard → **Database → Webhooks → Create**:
- **Table:** `public.notifications`
- **Events:** `Insert`
- **Type:** Supabase Edge Functions → **send-push**
- Method `POST` (o header de Authorization com a service role key já vai por padrão).

Pronto. Fluxo final:
`booking muda → trigger insere em notifications → webhook chama send-push →
FCM entrega o push aos device_tokens do destinatário` — mesmo com o app fechado.

## 7. Rebuild e testar
```bash
flutter build apk --release \
  --dart-define=SUPABASE_URL=... \
  --dart-define=SUPABASE_KEY=sb_publishable_...
```
Logue em 2 dispositivos/contas (cliente e tatuador), faça um agendamento e aprove —
o push chega no outro aparelho mesmo com o app fechado.

> iOS: precisa de APNs (conta Apple Developer) + ativar push no Xcode. Fora de escopo
> por enquanto (o app é Android).
