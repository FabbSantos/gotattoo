# Monetização — GoTattoo (modelo P2P)

> Decisão tomada: **pagamento P2P** (cliente paga o tatuador direto, na maquininha/Pix
> dele). O app é descoberta + agendamento + chat. A plataforma **não toca no dinheiro**
> da tatuagem → não dá pra pegar % por transação. Monetiza-se **por fora** da transação.
> Pedido do dono: começar **leve**, não é o foco agora.

## Princípio
Como não passamos o pagamento, a monetização vem de **valor para o tatuador** (visibilidade,
ferramentas, confiança) — não de taxa sobre a venda. Modelo tipo OLX/iFood-classificados.

## Opções (ranqueadas pela relação valor × esforço)

### 1. Assinatura do tatuador — "Plano Pro" ⭐ (aposta principal)
- **Free: SEM limitação** — perfil completo, agendamento, chat, portfólio. O Free não tolhe
  nada; o Pro só **leva o cara pra cima**.
- **Pro (mensal):** **Destaque** no topo + selo, **Verificado**, (e dá pra somar prioridade
  na busca / métricas depois). É elevação, não desbloqueio.
- **Cobrança: NÃO agora.** Sem billing no MVP — a flag `featured`/verificado é setada na mão.
  Quando ligar, o tatuador paga a plataforma (Pix recorrente / Asaas / Stripe billing).

### 2. Destaque / Impulsionamento (base JÁ construída ✅)
- Flag `featured` no perfil → aparece **primeiro** + selo ⭐ (migration `0012`, já feito).
- Monetizar: ou vem junto do Pro, ou **avulso** ("impulsione por 7 dias por R$X").
- Hoje a flag é setada manualmente (sem billing) — é a fundação pronta pro pago.

### 3. Taxa por lead / agendamento fechado
- Cobrar um valor **fixo** por agendamento confirmado (ex.: R$ 2–5), não % da tattoo.
- Precisa cobrar do tatuador (mensal acumulado, ou pré-pago em créditos).

### 4. Selo "Verificado" / confiança (pago)
- Verificação de identidade/portfólio → selo que aumenta conversão. Pode ser parte do Pro.

### 5. Anúncios (aprovado, mas com parcimônia)
- **Sim, mas poucos** — sem poluir. Ex.: 1 espaço nativo a cada N itens no feed, ou
  anúncios de **fornecedores do ramo** (tintas, agulhas, mobiliário). Nada de banner agressivo.

### 6. Futuro / lateral
- **Pagamento in-app opcional via Asaas** (Pix + cartão parcelado, com split) — aí sim
  pega % de quem optar por pagar no app. Híbrido: P2P padrão + "pagar no app" premium.
  A arquitetura atual (`PaymentService` + Edge Functions) migra direto pra isso.

## Recomendação (faseado, leve)
1. **Agora:** Free + **Destaque** (já temos). **Não cobrar nada** — validar uso e ver quem
   quer aparecer mais. Setar `featured` na mão pros primeiros parceiros.
2. **Depois:** empacotar o **Plano Pro** (Destaque + portfólio + verificado + métricas) e
   ligar a cobrança (Pix recorrente / Asaas / Stripe billing). Preço baixo (ex.: R$ 19–39/mês).
3. **Talvez:** "pagar no app" via Asaas como premium opcional (recupera a % de quem usar).

## Taxa de 3% — REMOVIDA ✅
Decisão tomada: a taxa de 3% (`PlatformFee`) **não faz sentido no P2P** (a plataforma não
coleta) e foi **removida**. O tatuador fica com 100% — o app é gratuito; a monetização vem
de **Pro/Destaque + anúncios leves**. Telas ajustadas: dashboard (faturamento bruto, sem taxa),
formulário de tatuagem (sem breakdown de taxa) e vendas (valor cheio). `PlatformFee` deletado.

## Próxima feature (pedido do dono)
**Feed de "pedidos de tatuagem":** qualquer usuário publica uma ideia de tattoo que quer fazer
(descrição, referência, local do corpo, orçamento) num feed; os **tatuadores comentam e
chamam pra negociar** (abre o chat). Tela separada. — em construção.
