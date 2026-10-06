import 'package:flutter/material.dart';
import '../widgets/ratio_bar.dart';
import '../widgets/spatial_background.dart';
import '../l10n.dart';

/// 3D Interactive Tactical Formations & Battlefield Simulator
class FormationsScreen extends StatefulWidget {
  const FormationsScreen({super.key});

  @override
  State<FormationsScreen> createState() => _FormationsScreenState();
}

class _FormationsScreenState extends State<FormationsScreen> {
  int _selectedPreset = 0;
  double _marchCapacity = 145000;

  final List<Map<String, dynamic>> _presets = [
    {
      'title': 'Standard PvP Field Battle',
      'title_ja': '標準PvPフィールド戦',
      'tagline_ja': 'グランドマスター万能スタンダード',
      'doctrine_ja': '盾兵が敵前線のダメージを100%受け止めます。盾兵が40%を下回ると弓兵は即座に壊滅します。50/20/30なら弓兵が守られ、長期戦でも最大の持続火力を発揮できます。',
      'heroes_ja': '前衛タンク1（ブラッドリー/フリント/シーゲル）＋槍兵1（ゴードン/ウルサス）＋弓兵1（エディス/アイスリング）',
      'icon': '⚔️',
      'inf': 50,
      'lan': 20,
      'mar': 30,
      'badge': '50 / 20 / 30',
      'tagline': 'Grandmaster Universal Standard',
      'doctrine': 'Infantry absorbs 100% of enemy frontline damage. If infantry falls below 40%, your marksmen will be wiped out immediately. 50/20/30 gives your marksmen the protection needed to deal maximum sustained damage over extended fights.',
      'heroes': '1 Frontline Tank (Bradley/Flint/Seigel) + 1 Lancer (Gordon/Ursar) + 1 Marksman (Edith/Aisling)',
    },
    {
      'title': 'Bear Trap (Max PvE Damage)',
      'title_ja': '熊狩り（PvE最大火力）',
      'tagline_ja': '全力ダメージバースト',
      'doctrine_ja': '熊は部隊を倒したり負傷させたりしません！防御シールドや重装盾兵は不要。弓兵80%で総ダメージを最大化しましょう。',
      'heroes_ja': '集結参加リーダー: ジェシー（ダメージ+25%）。副将: ソユン（攻撃+20%）＋最高ステータスの弓兵',
      'icon': '🐻',
      'inf': 10,
      'lan': 10,
      'mar': 80,
      'badge': '10 / 10 / 80',
      'tagline': 'All-Out Damage Burst',
      'doctrine': 'The Bear Trap monster never kills or injures your troops! Defensive shields and heavy infantry are unnecessary. Pack 80% Marksmen to maximize total raw damage points.',
      'heroes': 'Joiner Lead: Jessie (+25% Damage). Deputies: Seo-yoon (+20% Atk) + Highest Stat Marksman',
    },
    {
      'title': 'Castle & Stronghold Defense',
      'title_ja': '城・要塞防衛',
      'tagline_ja': '難攻不落の城壁',
      'doctrine_ja': '太陽城やSvSで複数の敵集結を防衛する際、城壁は大量のバーストダメージを受けます。セルゲイやブラッドリーと盾兵60%で駐屯部隊の突破を防ぎます。',
      'heroes_ja': '駐屯リーダー: セルゲイ / ブラッドリー / ヘクター（防衛時HPバフ高め）',
      'icon': '🏰',
      'inf': 60,
      'lan': 20,
      'mar': 20,
      'badge': '60 / 20 / 20',
      'tagline': 'Impenetrable Wall Fortress',
      'doctrine': 'When defending against multiple incoming enemy rallies during Sunfire Castle or SvS, your wall absorbs immense burst damage. 60% Infantry with Sergey or Bradley ensures your garrison never gets breached.',
      'heroes': 'Garrison Lead: Sergey / Bradley / Hector with high defender health buffs.',
    },
    {
      'title': 'High Burst 4-1-1 Attack',
      'title_ja': '高火力4-1-1アタック',
      'tagline_ja': '高速拠点制圧',
      'doctrine_ja': '弱い敵都市や鋳造所拠点を素早く殲滅するための攻撃編成。盾兵40%の最低ラインを保ちつつ、弓兵の大火力を発揮します。',
      'heroes_ja': 'リーダー: フリント / ジェロニモ ＋ アロンソ / リン ＋ フィリー',
      'icon': '🎯',
      'inf': 40,
      'lan': 10,
      'mar': 50,
      'badge': '40 / 10 / 50',
      'tagline': 'Fast Node Clearance',
      'doctrine': 'An aggressive offensive lineup designed for quick wipeouts against weaker enemy cities and foundry nodes. Gives huge marksman burst while maintaining the 40% minimum infantry threshold.',
      'heroes': 'Lead: Flint / Jeronimo + Alonso / Lynn + Philly',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final active = _presets[_selectedPreset];
    final infCount = ((_marchCapacity * (active['inf'] as int)) / 100).round();
    final lanCount = ((_marchCapacity * (active['lan'] as int)) / 100).round();
    final marCount = ((_marchCapacity * (active['mar'] as int)) / 100).round();

    return Scaffold(
      backgroundColor: const Color(0xFF040812),
      body: Container(
        color: const Color(0xFF040812),
        child: SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Header Sliver
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.tr('Troop Formations', '部隊編成'),
                            style: TextStyle(
                              fontFamily: 'Outfit',
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                              color: Colors.white,
                              letterSpacing: 0.4,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            context.tr('3D Isometric Lineup & March Simulator', '3D編成＆行軍シミュレーター'),
                            style: TextStyle(fontSize: 12, color: Color(0xFF00F0FF)),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00F0FF).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFF00F0FF).withOpacity(0.4)),
                        ),
                        child: Row(
                          children: [
                            Text('🛡️ ', style: TextStyle(fontSize: 12)),
                            Text(
                              context.tr('Tactical Engine', '戦術エンジン'),
                              style: TextStyle(color: Color(0xFF00F0FF), fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Presets Selector Grid
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1.7,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final item = _presets[index];
                      final isSelected = index == _selectedPreset;

                      return GestureDetector(
                        onTap: () => setState(() => _selectedPreset = index),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: isSelected
                                  ? [
                                      const Color(0xFF00F0FF).withOpacity(0.25),
                                      const Color(0xFF0A1E38).withOpacity(0.95),
                                    ]
                                  : [
                                      const Color(0xFF0F192C).withOpacity(0.75),
                                      const Color(0xFF080E1A).withOpacity(0.85),
                                    ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF00F0FF)
                                  : const Color(0xFF38BDF8).withOpacity(0.2),
                              width: isSelected ? 1.6 : 1.0,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: const Color(0xFF00F0FF).withOpacity(0.2),
                                      blurRadius: 14,
                                    ),
                                  ]
                                : null,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                children: [
                                  Text(item['icon'], style: const TextStyle(fontSize: 20)),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      item[context.isJa ? 'title_ja' : 'title'],
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Outfit',
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color(0xFF00F0FF).withOpacity(0.2)
                                      : Colors.black.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  item['badge'],
                                  style: TextStyle(
                                    color: isSelected ? const Color(0xFF00F0FF) : const Color(0xFF94A3B8),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    childCount: _presets.length,
                  ),
                ),
              ),

              // 3D Isometric Battlefield Projection & Active Preset Box
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // 3D Isometric Battlefield Card
                      _buildIsometricBattlefield(active),
                      const SizedBox(height: 16),

                      // March Capacity Slider Container
                      _buildMarchCapacityCard(active, infCount, lanCount, marCount),
                      const SizedBox(height: 16),

                      // Strategic Doctrine Card
                      _buildDoctrineCard(active),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIsometricBattlefield(Map<String, dynamic> active) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF132238).withOpacity(0.85),
            const Color(0xFF0A1220).withOpacity(0.95),
          ],
        ),
        border: Border.all(color: const Color(0xFF00F0FF).withOpacity(0.3), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00F0FF).withOpacity(0.1),
            blurRadius: 20,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(active['icon'], style: const TextStyle(fontSize: 22)),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        active[context.isJa ? 'title_ja' : 'title'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Outfit',
                        ),
                      ),
                      Text(
                        active[context.isJa ? 'tagline_ja' : 'tagline'],
                        style: const TextStyle(color: Color(0xFF00F0FF), fontSize: 11.5),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFF00F0FF).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF00F0FF).withOpacity(0.6)),
                ),
                child: Text(
                  active['badge'],
                  style: const TextStyle(
                    color: Color(0xFF00F0FF),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // 3-Row Spatial Battlefield Grid
          _buildSquadRow(context.tr('🛡️ FRONTLINE', '🛡️ 前衛'), context.tr('Infantry Wall (Tank Barrier)', '盾兵の壁（タンク）'), '${active['inf']}%', const Color(0xFF00F0FF), const Color(0xFF0284C7)),
          const SizedBox(height: 8),
          _buildSquadRow(context.tr('🐎 MID-LANE', '🐎 中衛'), context.tr('Lancer Cavalry (Flank Infiltration)', '槍兵（側面突破）'), '${active['lan']}%', const Color(0xFFF59E0B), const Color(0xFFEA580C)),
          const SizedBox(height: 8),
          _buildSquadRow(context.tr('🏹 REARGUARD', '🏹 後衛'), context.tr('Marksman Siege (High-DPS Artillery)', '弓兵（高火力砲撃）'), '${active['mar']}%', const Color(0xFFEC4899), const Color(0xFFEF4444)),

          const SizedBox(height: 16),
          RatioBar(
            infantry: active['inf'] as int,
            lancer: active['lan'] as int,
            marksman: active['mar'] as int,
          ),
        ],
      ),
    );
  }

  Widget _buildSquadRow(String role, String label, String pct, Color glow, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.35),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: glow.withOpacity(0.35)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                role,
                style: TextStyle(
                  color: glow,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                label,
                style: const TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [bg, glow]),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              pct,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
                fontFamily: 'Outfit',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMarchCapacityCard(Map<String, dynamic> active, int infCount, int lanCount, int marCount) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F192C).withOpacity(0.75),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.tr('March Capacity Simulator', '行軍容量シミュレーター'),
                style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold, fontFamily: 'Outfit'),
              ),
              Text(
                '${_marchCapacity.round().toString().replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (m) => "${m[1]},")} Troops',
                style: const TextStyle(color: Color(0xFF00F0FF), fontSize: 15, fontWeight: FontWeight.bold, fontFamily: 'Outfit'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: const Color(0xFF00F0FF),
              inactiveTrackColor: Colors.white12,
              thumbColor: const Color(0xFF00F0FF),
              overlayColor: const Color(0xFF00F0FF).withOpacity(0.2),
              trackHeight: 4,
            ),
            child: Slider(
              value: _marchCapacity,
              min: 20000,
              max: 300000,
              divisions: 56,
              onChanged: (val) => setState(() => _marchCapacity = val),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildTroopCountBadge(context.tr('🔷 Infantry', '🔷 盾兵'), infCount, const Color(0xFF00F0FF)),
              _buildTroopCountBadge(context.tr('🔶 Lancer', '🔶 槍兵'), lanCount, const Color(0xFFF59E0B)),
              _buildTroopCountBadge(context.tr('🔴 Marksman', '🔴 弓兵'), marCount, const Color(0xFFEC4899)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTroopCountBadge(String label, int count, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11)),
        const SizedBox(height: 3),
        Text(
          count.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},'),
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 14,
            fontFamily: 'Outfit',
          ),
        ),
      ],
    );
  }

  Widget _buildDoctrineCard(Map<String, dynamic> active) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F192C).withOpacity(0.75),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('📜 ', style: TextStyle(fontSize: 16)),
              Text(
                context.tr('Grandmaster Battle Doctrine', 'グランドマスター戦闘ドクトリン'),
                style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold, fontFamily: 'Outfit'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            active[context.isJa ? 'doctrine_ja' : 'doctrine'],
            style: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 12.5, height: 1.45),
          ),
          const SizedBox(height: 12),
          const Divider(color: Colors.white10),
          const SizedBox(height: 8),
          Text(
            context.tr('Recommended Hero Squad:', 'おすすめ英雄編成：'),
            style: TextStyle(color: Color(0xFF00F0FF), fontSize: 12, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            active[context.isJa ? 'heroes_ja' : 'heroes'],
            style: const TextStyle(color: Color(0xFFE2E8F0), fontSize: 12.5, height: 1.35),
          ),
        ],
      ),
    );
  }
}
