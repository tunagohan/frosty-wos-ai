import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:provider/provider.dart';
import '../models/chat_message.dart';
import '../l10n.dart';
import '../services/ai_service.dart';
import '../widgets/typing_indicator.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<String> get _quickPrompts => [
    context.tr('🐻 Bear Trap Joiner Lineup', '🐻 熊狩りの集結参加編成'),
    context.tr('👑 Write about Generation 16', '👑 第16世代について解説'),
    context.tr('🔥 How to build Flint (Gen 2)', '🔥 フリント（第2世代）の育成方法'),
    context.tr('⚔️ Best PvP 50/20/30 Squad', '⚔️ 最強PvP 50/20/30編成'),
    context.tr('🎯 Crazy Joe Wave 10/20 Guide', '🎯 クレイジージョー 10/20波攻略'),
  ];

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _send(AIService aiService, String text) {
    if (text.trim().isEmpty) return;
    _textController.clear();
    aiService.sendMessage(text);
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final aiService = Provider.of<AIService>(context);

    // Auto-scroll on new message
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    return Scaffold(
      backgroundColor: const Color(0xFF040812),
      appBar: AppBar(
        backgroundColor: const Color(0xFF070D18),
        elevation: 0,
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const RadialGradient(
                  colors: [Color(0xFF00F0FF), Color(0xFF0284C7)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00F0FF).withOpacity(0.4),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: const Center(
                child: Text('❄️', style: TextStyle(fontSize: 18)),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr('Frosty Tactical Oracle', 'Frosty 戦術オラクル'),
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    fontWeight: FontWeight.bold,
                    fontSize: 16.5,
                    color: Colors.white,
                    letterSpacing: 0.3,
                  ),
                ),
                Text(
                  'Gemini 2.5 • ChromaDB RAG • Gen 0-16+',
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFF00F0FF),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFF94A3B8)),
            tooltip: context.tr('Clear Chat History', 'チャット履歴を消去'),
            onPressed: () => aiService.clearConversation(),
          ),
        ],
      ),
      body: Container(
        color: const Color(0xFF040812),
        child: Column(
          children: [
            // Quick Suggestion Chips Carousel
            Container(
              height: 52,
              padding: const EdgeInsets.symmetric(vertical: 8),
              color: const Color(0xFF070D18),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                itemCount: _quickPrompts.length,
                itemBuilder: (context, index) {
                  final prompt = _quickPrompts[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => _send(aiService, prompt),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F192C),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFF00F0FF).withOpacity(0.35),
                            width: 1.1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            prompt,
                            style: const TextStyle(
                              color: Color(0xFFE2E8F0),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Outfit',
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const Divider(height: 1, color: Color(0xFF1E293B)),

            // Messages Stream or Empty State
            Expanded(
              child: aiService.messages.isEmpty && !aiService.isGenerating
                  ? _buildEmptyState(aiService)
                  : ListView.builder(
                      controller: _scrollController,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      itemCount: aiService.messages.length + (aiService.isGenerating ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == aiService.messages.length) {
                          return const FrostyTypingIndicator();
                        }

                        final msg = aiService.messages[index];
                        return _buildMessageBubble(msg);
                      },
                    ),
            ),

            // Floating Input Dock
            _buildInputBar(aiService),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(AIService aiService) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF0A1424),
              border: Border.all(color: const Color(0xFF00F0FF).withOpacity(0.4), width: 2),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00F0FF).withOpacity(0.2),
                  blurRadius: 20,
                ),
              ],
            ),
            child: const Center(
              child: Text('❄️', style: TextStyle(fontSize: 36)),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            context.tr('Frosty Tactical Command', 'Frosty 戦術司令部'),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFamily: 'Outfit',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            context.tr('Ask any question regarding Whiteout Survival formations, heroes, Bear Trap, or event guides.', 'ホワイトアウト・サバイバルの編成、英雄、熊狩り、イベント攻略について何でも質問してください。'),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.5,
              color: Color(0xFF94A3B8),
              height: 1.45,
            ),
          ),
          const SizedBox(height: 24),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              context.tr('Recommended Strategic Inquiries:', 'おすすめの戦略質問：'),
              style: TextStyle(
                color: Color(0xFF00F0FF),
                fontSize: 12.5,
                fontWeight: FontWeight.bold,
                fontFamily: 'Outfit',
                letterSpacing: 0.3,
              ),
            ),
          ),
          const SizedBox(height: 12),
          _buildPromptCard(
            aiService,
            context.tr('🐻 Best Bear Trap Lineup & Joiner Buffs', '🐻 熊狩りの最強編成と集結参加バフ'),
            context.tr('Optimal 10/10/80 ratio and top 4 joiner hero buffs (Jessie +25%, Seo-yoon +20%).', '最適な10/10/80比率と集結参加英雄バフ上位4つ（ジェシー+25%、ソユン+20%）。'),
            context.tr('What is the optimal Bear Trap troop ratio and who are the best rally leader and joiner heroes?', '熊狩りの最適な兵種比率と、最強の集結リーダー・参加英雄は誰ですか？'),
          ),
          const SizedBox(height: 10),
          _buildPromptCard(
            aiService,
            context.tr('👑 Generation 16 Hero Breakdown', '👑 第16世代英雄の徹底解説'),
            context.tr('Full breakdown of Seigel (Infantry), Ursar (Lancer), and Aisling (Marksman).', 'シーゲル（盾兵）、ウルサー（槍兵）、アイスリン（弓兵）を徹底解説。'),
            context.tr('Give a full tactical evaluation of Generation 16 heroes (Seigel, Ursar, Aisling) and F2P advice.', '第16世代英雄（シーゲル、ウルサー、アイスリン）の戦術評価と無課金向けアドバイスを教えてください。'),
          ),
          const SizedBox(height: 10),
          _buildPromptCard(
            aiService,
            context.tr('⚔️ Standard PvP 50/20/30 Formation Doctrine', '⚔️ PvP標準 50/20/30 編成理論'),
            context.tr('Why 50% infantry is mandatory and how to structure your 3-hero squad.', '盾兵50%が必須な理由と、3英雄部隊の組み方。'),
            context.tr('Explain the 50/20/30 formation in Whiteout Survival and why Infantry frontline is essential.', 'ホワイトアウト・サバイバルの50/20/30編成と、盾兵の前衛が不可欠な理由を説明してください。'),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildPromptCard(AIService aiService, String title, String subtitle, String query) {
    return GestureDetector(
      onTap: () => _send(aiService, query),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF0F192C),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF00F0FF).withOpacity(0.25), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13.5,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Outfit',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Color(0xFF00F0FF)),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage msg) {
    final isUser = msg.isUser;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.88,
        ),
        decoration: BoxDecoration(
          color: isUser ? const Color(0xFF0284C7) : const Color(0xFF0F1A2E),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isUser ? 18 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 18),
          ),
          border: Border.all(
            color: isUser
                ? const Color(0xFF38BDF8)
                : const Color(0xFF00F0FF).withOpacity(0.4),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header tag for assistant response
              if (!isUser) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Text('❄️', style: TextStyle(fontSize: 14)),
                        const SizedBox(width: 6),
                        Text(
                          msg.modelUsed ?? 'Frosty Oracle',
                          style: const TextStyle(
                            color: Color(0xFF00F0FF),
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy_rounded, size: 16, color: Color(0xFF94A3B8)),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      tooltip: context.tr('Copy Answer', '回答をコピー'),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: msg.text));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(context.tr('📋 Copied tactical advice to clipboard!', '📋 戦術アドバイスをクリップボードにコピーしました！')),
                            duration: const Duration(seconds: 2),
                            backgroundColor: const Color(0xFF0284C7),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Divider(color: Colors.white12, height: 1),
                const SizedBox(height: 8),
              ],

              // Markdown Content with Explicit High-Contrast Text Styles
              MarkdownBody(
                data: msg.text,
                selectable: true,
                styleSheet: MarkdownStyleSheet(
                  p: const TextStyle(
                    color: Color(0xFFF8FAFC),
                    fontSize: 13.5,
                    height: 1.5,
                  ),
                  strong: const TextStyle(
                    color: Color(0xFF00F0FF),
                    fontWeight: FontWeight.bold,
                  ),
                  em: const TextStyle(
                    color: Color(0xFFE2E8F0),
                    fontStyle: FontStyle.italic,
                  ),
                  h1: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Outfit',
                  ),
                  h2: const TextStyle(
                    color: Color(0xFF00F0FF),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Outfit',
                  ),
                  h3: const TextStyle(
                    color: Color(0xFF38BDF8),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  listBullet: const TextStyle(
                    color: Color(0xFF00F0FF),
                    fontSize: 14,
                  ),
                  code: const TextStyle(
                    backgroundColor: Color(0xFF060B14),
                    color: Color(0xFF00F0FF),
                    fontFamily: 'monospace',
                    fontSize: 12,
                  ),
                  blockquote: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 13,
                  ),
                  blockquoteDecoration: BoxDecoration(
                    color: const Color(0xFF060B14),
                    borderRadius: BorderRadius.circular(6),
                    border: const Border(
                      left: BorderSide(color: Color(0xFF00F0FF), width: 3),
                    ),
                  ),
                  tableBody: const TextStyle(color: Color(0xFFF8FAFC), fontSize: 12.5),
                  tableHead: const TextStyle(color: Color(0xFF00F0FF), fontWeight: FontWeight.bold, fontSize: 13),
                  tableBorder: TableBorder.all(color: Colors.white24, width: 0.8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputBar(AIService aiService) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: const BoxDecoration(
        color: Color(0xFF070D18),
        border: Border(top: BorderSide(color: Color(0xFF1E293B))),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F192C),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: const Color(0xFF00F0FF).withOpacity(0.3),
                    width: 1.2,
                  ),
                ),
                child: TextField(
                  controller: _textController,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  textInputAction: TextInputAction.send,
                  onSubmitted: (text) => _send(aiService, text),
                  decoration: InputDecoration(
                    hintText: context.tr('Ask Frosty (e.g. Bear Trap, Gen 16, 50/20/30)...', 'Frostyに質問（例：熊狩り、第16世代、50/20/30）...'),
                    hintStyle: TextStyle(color: Color(0xFF64748B), fontSize: 13),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const RadialGradient(
                  colors: [Color(0xFF00F0FF), Color(0xFF0284C7)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00F0FF).withOpacity(0.35),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(Icons.send_rounded, color: Color(0xFF040812), size: 20),
                onPressed: () => _send(aiService, _textController.text),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
