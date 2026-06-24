# Segurança — GoTattoo

Resumo da postura de segurança + o que ainda depende de você (toggles no Supabase).

## ✅ O que já está bom

### SQL injection — praticamente não existe aqui
O app e as Edge Functions **nunca montam SQL com texto**. Tudo passa pelo SDK do
Supabase (`.from().select().eq()`, `.rpc(params: {...})`) e pelo SDK do Stripe — que
são **parametrizados** (os valores vão separados da query). O único SQL "cru" são as
**migrations estáticas** (escritas por nós, sem input de usuário). Então o vetor clássico
de injection não se aplica. O risco real num app Supabase é **RLS**, não injection.

### RLS (Row Level Security) — 100% das tabelas
As 14 tabelas têm RLS **habilitado** com policies por dono/papel:
profiles, products, categories, orders, order_items, bookings, artist_availability,
reviews, notifications, device_tokens, conversations, messages, tattoo_requests,
tattoo_request_comments. Cada um só lê/escreve o que pode.

### Segredos — nada vaza no app
- O app só carrega a **publishable/anon key** (feita pra ser pública).
- A **service_role key** e a **STRIPE_SECRET_KEY** só existem nas **Edge Functions** (servidor).
- Varredura no `lib/` por `service_role`/`sk_`/`secret`: **nada encontrado**.

### Edge Functions autorizam o chamador
Resolvem o usuário pelo JWT (`callerId`) e checam permissão (ex.: `charge-booking`
confirma que o tatuador é dono do booking). Funções `security definer` têm
`set search_path` (evita ataque de search_path).

## 🔧 Corrigido nesta auditoria
- **Escalada de privilégio em `profiles`** (migration `0015`): o RLS deixava o usuário
  editar o próprio perfil, mas não dava pra restringir colunas — então dava pra se
  auto-setar `role='artist'` ou `featured=true`. Um trigger agora **congela `role` e
  `featured`** em updates de usuário (admin via SQL Editor segue funcionando).

## ⚠️ A revisar (recomendações)
- **Dados de payout públicos:** `profiles` é leitura pública e inclui
  `payout_provider`/`payout_identifier` (Pix/PayPal do tatuador). Como o modelo é P2P e
  esses campos estão depreciados, o ideal é **removê-los** ou movê-los pra uma tabela
  com RLS só-do-dono. Risco baixo hoje (quase ninguém preenche), mas é um vazamento.

## 🔒 Você precisa ligar no Dashboard do Supabase (Auth → Settings)
São toggles, não código:
- [ ] **Confirmar e-mail** (Confirm email) — evita cadastro com e-mail de terceiros.
- [ ] **Proteção de senha vazada** (Leaked password protection / HaveIBeenPwned).
- [ ] **Tamanho mínimo de senha** (ex.: 8+).
- [ ] Conferir **rate limits** de auth (o Supabase já tem padrões).
- [ ] (Quando for produção) revisar **OTP/expiração de e-mail**.

## 🆕 Próximo: Login com Google
Aumenta segurança (sem senha pra vazar) e conversão. Precisa:
1. Criar credencial OAuth no **Google Cloud** (já existe o projeto do Firebase).
2. Habilitar o provider **Google** no Supabase (Auth → Providers).
3. No app: `signInWithIdToken` (fluxo nativo) + deep link.
Posso montar o lado do app quando você criar a credencial.
