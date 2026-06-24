# Publicar o GoTattoo (Google Play) — checklist

Passos pra tirar o app do "roda no meu celular" e colocar na **Play Store**.

## 1. Identidade do app (uma vez)
- [ ] **Package name definitivo.** Hoje é `com.example.gotattoo` — a Play **não aceita**
  `com.example.*`. Trocar para algo seu, ex.: `br.com.gotattoo.app`.
  - Muda em: `android/app/build.gradle.kts` (`applicationId` + `namespace`),
    `MainActivity.kt` (package + pasta `kotlin/...`), `google-services.json`
    (precisa registrar esse package no Firebase) e no AdMob.
- [x] **Ícone** (já feito, adaptativo).
- [ ] **Versão:** definir `version: 1.0.0+1` no `pubspec.yaml` (nome+build).

## 2. Assinatura de release (uma vez) 🔑
Hoje o release assina com a **debug key** (TODO no `build.gradle.kts`). Pra Play precisa
de uma **keystore própria**:
```bash
keytool -genkey -v -keystore gotattoo-release.jks \
  -keyalg RSA -keysize 2048 -validity 10000 -alias gotattoo
```
- Guarde o `.jks` e as senhas **com a vida** (perdeu = não atualiza mais o app).
- Crie `android/key.properties` (NÃO commitar) e referencie no `build.gradle.kts`
  (`signingConfigs`). Posso configurar isso quando você gerar a keystore.

## 3. Build de release pra loja
A Play prefere **App Bundle** (`.aab`), não APK:
```bash
flutter build appbundle --release \
  --dart-define=SUPABASE_URL=... \
  --dart-define=SUPABASE_KEY=sb_publishable_... \
  --dart-define=ADMOB_BANNER_ID=ca-app-pub-SEU/SEU
```

## 4. Serviços externos em produção
- [ ] **Firebase/FCM:** registrar o package novo + baixar `google-services.json` atualizado.
- [ ] **AdMob:** criar conta, registrar o app, pegar o **App ID real** (trocar no
  `AndroidManifest.xml`) e o **banner unit id** (passar no `--dart-define`). Preencher
  dados de pagamento pra receber.
- [ ] **Supabase:** já está em produção (o mesmo projeto). Conferir RLS.
- [ ] **Stripe:** dormente (P2P) — ignorar por enquanto.

## 5. Conta e ficha da Play
- [ ] **Google Play Console** (taxa única US$25).
- [ ] Ficha: nome, descrição, **screenshots**, ícone 512px, banner 1024x500.
- [ ] **Política de privacidade** (URL obrigatória — ainda mais com login, localização,
  notificações e **anúncios/AdMob** que coletam dados).
- [ ] Questionário de **Data safety** (declarar dados coletados: conta, localização, ads).
- [ ] Classificação indicativa.

## 6. Permissões a justificar
O app pede: Internet, Localização (tatuadores por perto), Notificações, AdMob (AD_ID).
A localização e o AD_ID exigem justificativa no formulário da Play.

## 7. Lançamento
- [ ] Subir o `.aab` em **teste interno** primeiro (rápido, sua conta) → validar.
- [ ] Depois **produção** (revisão da Google leva de horas a alguns dias).

---
### Ordem sugerida
1. Trocar package name + versão.  2. Gerar keystore + configurar assinatura.
3. Criar AdMob + Play Console.  4. Atualizar `google-services.json`.
5. `flutter build appbundle` e subir em teste interno.

> Me avisa quando quiser começar — dá pra eu já fazer a troca do package name e a
> config de assinatura (você só gera a keystore com o comando acima).
