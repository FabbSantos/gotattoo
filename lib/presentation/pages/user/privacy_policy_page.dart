import 'package:flutter/material.dart';

/// In-app privacy policy. The same text is mirrored in docs/PRIVACY_POLICY.md,
/// which is what gets hosted for the Play Store listing's required URL.
class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  static const _updatedAt = '24 de junho de 2026';

  static const _sections = <(String, String)>[
    (
      '',
      'O GoTattoo conecta clientes a tatuadores. Esta política explica quais '
          'dados coletamos, como usamos e quais são os seus direitos. Ao usar o '
          'app, você concorda com o aqui descrito.',
    ),
    (
      '1. Dados que coletamos',
      '• Conta: nome, e-mail e foto de perfil. Tatuadores também informam um '
          'link de portfólio.\n'
          '• Localização: usada só quando você toca para definir (estúdio do '
          'tatuador ou proximidade do cliente). Nunca em segundo plano.\n'
          '• Conteúdo: posts, comentários, curtidas, avaliações, tatuagens e '
          'mensagens de chat.\n'
          '• Notificações: um identificador de dispositivo para avisos.\n'
          '• Anúncios: o Google AdMob pode coletar identificadores do '
          'dispositivo para exibir e medir anúncios.',
    ),
    (
      '2. Como usamos',
      'Para operar o app (login, perfis, agendamentos, mural, chat e '
          'avaliações), mostrar tatuadores próximos, enviar notificações e '
          'exibir anúncios que mantêm o app gratuito. Não vendemos seus dados. '
          'O pagamento é combinado direto entre cliente e tatuador, fora do app.',
    ),
    (
      '3. Terceiros',
      'Supabase (banco de dados e autenticação) e Google (Login, notificações '
          'via Firebase e anúncios via AdMob). Cada um trata os dados conforme '
          'suas próprias políticas.',
    ),
    (
      '4. Seus direitos',
      'Você pode editar seu perfil a qualquer momento. Para excluir sua conta e '
          'seus dados, ou tirar dúvidas, fale com a gente pelo app em '
          'Conta → Ajuda e Suporte.',
    ),
    (
      '5. Retenção',
      'Mantemos seus dados enquanto a conta existir. Ao excluir, removemos seus '
          'dados pessoais (cópias podem permanecer brevemente em backups).',
    ),
    (
      '6. Crianças',
      'O app não é destinado a menores de 18 anos.',
    ),
    (
      '7. Contato',
      'Dúvidas? Fale com a gente pelo app, em Conta → Ajuda e Suporte.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Política de Privacidade')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Última atualização: $_updatedAt',
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
          const SizedBox(height: 16),
          for (final (title, body) in _sections) ...[
            if (title.isNotEmpty) ...[
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
            ],
            SelectableText(
              body,
              style: const TextStyle(fontSize: 14, height: 1.4),
            ),
            const SizedBox(height: 18),
          ],
        ],
      ),
    );
  }
}
