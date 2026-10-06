import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/ai_service.dart';
import '../services/update_service.dart';
import '../l10n.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static const String repoUrl = 'https://github.com/Zcross091/frosty-wos-ai';
  static const String issuesUrl = 'https://github.com/Zcross091/frosty-wos-ai/issues/new';
  static const String forkUrl = 'https://github.com/Zcross091/frosty-wos-ai/fork';
  static const String pullsUrl = 'https://github.com/Zcross091/frosty-wos-ai/pulls';
  static const String discordInviteUrl = 'https://discord.com/oauth2/authorize?client_id=1501632240466006108&permissions=347200&integration_type=0&scope=bot+applications.commands';

  Future<void> _launchUrl(String urlStr) async {
    final uri = Uri.parse(urlStr);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {}
  }

  void _showApiKeyDialog(BuildContext context, AIService aiService) {
    final backendController = TextEditingController(text: aiService.backendUrl);
    final geminiController = TextEditingController(text: aiService.geminiKey);
    final groqController = TextEditingController(text: aiService.groqKey);
    final ollamaHostController = TextEditingController(text: aiService.ollamaHost);

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0F192C),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: const BorderSide(color: Color(0xFF00F0FF), width: 1.2),
          ),
          title: Row(
            children: [
              Text('🔑 ', style: TextStyle(fontSize: 18)),
              Text(
                context.tr('AI Endpoints & Keys', 'AIエンドポイントとキー'),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontFamily: 'Outfit',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: backendController,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: InputDecoration(
                    labelText: context.tr('Frosty Central Server URL', 'Frosty中央サーバーURL'),
                    labelStyle: TextStyle(color: Color(0xFF00F0FF), fontSize: 12, fontWeight: FontWeight.bold),
                    hintText: 'http://your-server-ip:8000',
                    hintStyle: TextStyle(color: Color(0xFF64748B), fontSize: 11),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: geminiController,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: InputDecoration(
                    labelText: context.tr('Google Gemini API Key (Direct)', 'Google Gemini APIキー（直接）'),
                    labelStyle: TextStyle(color: Color(0xFF38BDF8), fontSize: 12),
                    hintText: 'AQ... or AIzaSy...',
                    hintStyle: TextStyle(color: Color(0xFF64748B), fontSize: 11),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: groqController,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: InputDecoration(
                    labelText: context.tr('Groq API Key (Direct)', 'Groq APIキー（直接）'),
                    labelStyle: TextStyle(color: Color(0xFF38BDF8), fontSize: 12),
                    hintText: 'gsk_...',
                    hintStyle: TextStyle(color: Color(0xFF64748B), fontSize: 11),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: ollamaHostController,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: InputDecoration(
                    labelText: context.tr('Local Ollama Host URL', 'ローカルOllamaホストURL'),
                    labelStyle: TextStyle(color: Color(0xFF38BDF8), fontSize: 12),
                    hintText: 'http://192.168.1.100:11434',
                    hintStyle: TextStyle(color: Color(0xFF64748B), fontSize: 11),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(context.tr('Cancel', 'キャンセル'), style: TextStyle(color: Color(0xFF94A3B8))),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00F0FF),
                foregroundColor: const Color(0xFF040914),
              ),
              onPressed: () {
                aiService.updateSettings(
                  backendUrl: backendController.text,
                  geminiKey: geminiController.text,
                  groqKey: groqController.text,
                  ollamaHost: ollamaHostController.text,
                );
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(context.tr('✅ Central Backend & AI settings saved!', '✅ 中央バックエンドとAI設定を保存しました！')),
                    backgroundColor: Color(0xFF22C55E),
                  ),
                );
              },
              child: Text(context.tr('Save Keys', 'キーを保存'), style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final aiService = Provider.of<AIService>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF060B13),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A111F).withOpacity(0.9),
        elevation: 0,
        title: Row(
          children: [
            Text('⚙️ ', style: TextStyle(fontSize: 18)),
            Text(
              context.tr('Settings & Community', '設定とコミュニティ'),
              style: TextStyle(
                fontFamily: 'Outfit',
                fontWeight: FontWeight.bold,
                fontSize: 17,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Author & Project Banner (Made by StateCraft)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0F192C), Color(0xFF1E293B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF00F0FF).withOpacity(0.4), width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00F0FF).withOpacity(0.12),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text('❄️', style: TextStyle(fontSize: 40)),
                  const SizedBox(height: 8),
                  const Text(
                    'Frosty WOS AI',
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00F0FF).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFF00F0FF)),
                    ),
                    child: const Text(
                      'Made by StateCraft',
                      style: TextStyle(
                        color: Color(0xFF00F0FF),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    context.tr('The open-source AI grandmaster companion for Whiteout Survival Chiefs worldwide.', '世界中のホワイトアウト・サバイバル首長のための、オープンソースAIグランドマスター。'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 12.5,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // GitHub Community Hub Section
            Text(
              context.tr('🌟 Open Source & Community Hub', '🌟 オープンソース＆コミュニティ'),
              style: TextStyle(
                color: Color(0xFF00F0FF),
                fontSize: 14,
                fontWeight: FontWeight.bold,
                fontFamily: 'Outfit',
              ),
            ),
            const SizedBox(height: 10),

            _buildActionTile(
              icon: Icons.system_update_rounded,
              title: context.tr('Check for Updates', 'アップデートを確認'),
              subtitle: context.tr('Check GitHub releases for latest Frosty app APK update', 'GitHubリリースで最新のFrostyアプリAPKを確認'),
              color: const Color(0xFF00F0FF),
              onTap: () => UpdateService.checkForUpdates(context, manualCheck: true),
            ),
            _buildActionTile(
              icon: Icons.bug_report_rounded,
              title: context.tr('Post / Report Issues', '問題を報告'),
              subtitle: context.tr('Submit bugs, request features, or report data inconsistencies', 'バグ報告、機能リクエスト、データの不整合を報告'),
              color: const Color(0xFFEF4444),
              onTap: () => _launchUrl(issuesUrl),
            ),
            _buildActionTile(
              icon: Icons.star_rounded,
              title: context.tr('Star on GitHub', 'GitHubでスターする'),
              subtitle: context.tr('Support Frosty by leaving a star on our official repository', '公式リポジトリにスターを付けてFrostyを応援'),
              color: const Color(0xFFF59E0B),
              onTap: () => _launchUrl(repoUrl),
            ),
            _buildActionTile(
              icon: Icons.call_split_rounded,
              title: context.tr('Fork Repository', 'リポジトリをフォーク'),
              subtitle: context.tr('Create your own custom branch of Frosty', 'Frostyの独自ブランチを作成'),
              color: const Color(0xFF3B82F6),
              onTap: () => _launchUrl(forkUrl),
            ),
            _buildActionTile(
              icon: Icons.volunteer_activism_rounded,
              title: context.tr('Contribute to Project', 'プロジェクトに貢献'),
              subtitle: context.tr('Submit pull requests, new hero guides, or UI improvements', 'プルリクエスト、新しい英雄ガイド、UI改善を投稿'),
              color: const Color(0xFF22C55E),
              onTap: () => _launchUrl(pullsUrl),
            ),
            _buildActionTile(
              icon: Icons.discord,
              title: context.tr('Invite Frosty to Discord', 'FrostyをDiscordに招待'),
              subtitle: context.tr('Add the 24/7 AI tactical oracle to your alliance server', '24時間対応のAI戦術オラクルを同盟サーバーに追加'),
              color: const Color(0xFF5865F2),
              onTap: () => _launchUrl(discordInviteUrl),
            ),

            const SizedBox(height: 24),

            // Language
            Text(
              context.tr('🌐 Language', '🌐 言語'),
              style: const TextStyle(
                color: Color(0xFF00F0FF),
                fontSize: 14,
                fontWeight: FontWeight.bold,
                fontFamily: 'Outfit',
              ),
            ),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF0F192C),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF38BDF8).withOpacity(0.2)),
              ),
              child: ListTile(
                leading: const Icon(Icons.translate_rounded, color: Color(0xFF00F0FF)),
                title: Text(context.tr('App Language', 'アプリの言語'), style: const TextStyle(color: Colors.white, fontSize: 14)),
                trailing: DropdownButton<String>(
                  value: aiService.language,
                  dropdownColor: const Color(0xFF0F192C),
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  underline: const SizedBox(),
                  items: const [
                    DropdownMenuItem(value: 'en', child: Text('English')),
                    DropdownMenuItem(value: 'ja', child: Text('日本語')),
                  ],
                  onChanged: (val) {
                    if (val != null) aiService.updateSettings(language: val);
                  },
                ),
              ),
            ),

            const SizedBox(height: 24),

            // AI Configuration
            Text(
              context.tr('🧠 AI Provider & Key Settings', '🧠 AIプロバイダーとキー設定'),
              style: TextStyle(
                color: Color(0xFF00F0FF),
                fontSize: 14,
                fontWeight: FontWeight.bold,
                fontFamily: 'Outfit',
              ),
            ),
            const SizedBox(height: 10),

            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF0F192C),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF38BDF8).withOpacity(0.2)),
              ),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                child: Column(
                  children: [
                    ListTile(
                      title: Text(context.tr('Primary Provider Mode', 'メインプロバイダー'), style: TextStyle(color: Colors.white, fontSize: 14)),
                      subtitle: Text(
                        '${context.tr('Current', '現在')}: ${aiService.currentProvider.toUpperCase()}',
                        style: const TextStyle(color: Color(0xFF00F0FF), fontSize: 12),
                      ),
                      trailing: DropdownButton<String>(
                        value: aiService.currentProvider,
                        dropdownColor: const Color(0xFF0F192C),
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                        underline: const SizedBox(),
                        items: [
                          DropdownMenuItem(value: 'auto', child: Text(context.tr('Auto (Gemini -> Groq -> Local)', '自動 (Gemini -> Groq -> ローカル)'))),
                          DropdownMenuItem(value: 'gemini', child: Text(context.tr('Gemini Only', 'Geminiのみ'))),
                          DropdownMenuItem(value: 'groq', child: Text(context.tr('Groq Only', 'Groqのみ'))),
                          DropdownMenuItem(value: 'ollama', child: Text(context.tr('Local Ollama', 'ローカルOllama'))),
                          DropdownMenuItem(value: 'offline', child: Text(context.tr('Offline Core Only', 'オフラインのみ'))),
                        ],
                        onChanged: (val) {
                          if (val != null) aiService.updateSettings(provider: val);
                        },
                      ),
                    ),
                    const Divider(height: 1, color: Color(0xFF1E293B)),
                    ListTile(
                      leading: const Icon(Icons.key_rounded, color: Color(0xFF00F0FF)),
                      title: Text(context.tr('Custom API Keys & Hosts', 'カスタムAPIキーとホスト'), style: TextStyle(color: Colors.white, fontSize: 14)),
                      subtitle: Text(context.tr('Enter custom Gemini, Groq, or Ollama LAN IP', 'Gemini・Groqのキー、OllamaのLAN IPを入力'), style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                      trailing: const Icon(Icons.chevron_right, color: Color(0xFF64748B)),
                      onTap: () => _showApiKeyDialog(context, aiService),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),
            Center(
              child: Text(
                context.tr('Frosty WOS AI Tactical Companion • Made by StateCraft\nLicensed under MIT • Open Source GitHub Edition', 'Frosty WOS AI 戦術コンパニオン • Made by StateCraft\nMITライセンス • オープンソース GitHub版'),
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF64748B), fontSize: 11.5),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF0F192C),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF38BDF8).withOpacity(0.18)),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: ListTile(
          leading: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: color.withOpacity(0.4)),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          title: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: const TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 11.5,
            ),
          ),
          trailing: const Icon(Icons.open_in_new_rounded, color: Color(0xFF64748B), size: 18),
          onTap: onTap,
        ),
      ),
    );
  }
}
