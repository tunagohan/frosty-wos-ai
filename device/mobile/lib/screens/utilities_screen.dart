import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/knowledge_service.dart';
import '../l10n.dart';

class UtilitiesScreen extends StatefulWidget {
  const UtilitiesScreen({super.key});

  @override
  State<UtilitiesScreen> createState() => _UtilitiesScreenState();
}

class _UtilitiesScreenState extends State<UtilitiesScreen> {
  int _activeTab = 0; // 0: FC Calc, 1: Charms, 2: SvS Points, 3: Bear Trap Simulator, 4: Transfer, 5: Gift Codes, 6: UTC Timers

  // FC Calculator State
  String _fcBuildingType = 'furnace';
  int _fcFromLevel = 0;
  int _fcToLevel = 5;

  // Charms Calculator State
  int _charmFromLevel = 0;
  int _charmToLevel = 5;

  // SvS Calculator State
  String _svsActivity = 'fc';
  final TextEditingController _svsAmountController = TextEditingController(text: '1000');

  // Bear Trap Simulator State
  final TextEditingController _bearMarchCapacityController = TextEditingController(text: '150000');
  String _bearTroopTier = 'T10';
  String _bearRatioPreset = '10/10/80';
  int _bearJoinerJessieCount = 4;

  // Transfer Calculator State
  final TextEditingController _transferPowerController = TextEditingController(text: '150');

  @override
  void dispose() {
    _svsAmountController.dispose();
    _bearMarchCapacityController.dispose();
    _transferPowerController.dispose();
    super.dispose();
  }

  // --- Dynamic Data Resolvers ---
  List<Map<String, String>> _resolveGiftCodes() {
    final dynamicData = KnowledgeService.dynamicUtilityData;
    if (dynamicData != null && dynamicData['gift_codes'] is List) {
      return (dynamicData['gift_codes'] as List).map<Map<String, String>>((item) {
        return {
          'code': item['code']?.toString() ?? '',
          'rewards': item['rewards']?.toString() ?? '',
        };
      }).toList();
    }
    return _defaultGiftCodes;
  }

  Map<int, List<num>> _resolveFcTable() {
    final dynamicData = KnowledgeService.dynamicUtilityData;
    if (dynamicData != null && dynamicData['fc_table'] is Map) {
      final Map<String, dynamic> raw = dynamicData['fc_table'];
      final Map<int, List<num>> res = {};
      raw.forEach((k, v) {
        final int? lvl = int.tryParse(k);
        if (lvl != null && v is Map) {
          res[lvl] = [
            v['furnace_fc'] ?? 0,
            v['furnace_rfc'] ?? 0,
            v['camp_fc'] ?? 0,
            v['camp_rfc'] ?? 0,
            v['days'] ?? 0,
          ];
        }
      });
      if (res.isNotEmpty) return res;
    }
    return _defaultFcTable;
  }

  Map<int, List<num>> _resolveCharmTable() {
    final dynamicData = KnowledgeService.dynamicUtilityData;
    if (dynamicData != null && dynamicData['charm_table'] is Map) {
      final Map<String, dynamic> raw = dynamicData['charm_table'];
      final Map<int, List<num>> res = {};
      raw.forEach((k, v) {
        final int? lvl = int.tryParse(k);
        if (lvl != null && v is Map) {
          res[lvl] = [
            v['guides'] ?? 0,
            v['designs'] ?? 0,
            v['boost'] ?? 0.0,
            v['svs_pts'] ?? 0,
          ];
        }
      });
      if (res.isNotEmpty) return res;
    }
    return _defaultCharmTable;
  }

  Map<String, Map<String, dynamic>> _resolveSvsRates() {
    final dynamicData = KnowledgeService.dynamicUtilityData;
    if (dynamicData != null && dynamicData['svs_rates'] is Map) {
      final Map<String, dynamic> raw = dynamicData['svs_rates'];
      final Map<String, Map<String, dynamic>> res = {};
      raw.forEach((k, v) {
        if (v is Map) {
          res[k] = Map<String, dynamic>.from(v);
        }
      });
      if (res.isNotEmpty) return res;
    }
    return _defaultSvsRates;
  }

  // --- Default Fallback Tables ---
  static const Map<int, List<num>> _defaultFcTable = {
    1: [600, 0, 350, 0, 8],
    2: [1200, 0, 700, 0, 12],
    3: [2000, 0, 1150, 0, 16],
    4: [3200, 0, 1800, 0, 22],
    5: [4800, 0, 2700, 0, 30],
    6: [2500, 180, 1400, 100, 40],
    7: [3500, 320, 1950, 180, 52],
    8: [5000, 550, 2800, 300, 65],
    9: [7000, 850, 3900, 480, 80],
    10: [10000, 1300, 5500, 720, 100],
    11: [14000, 1900, 7800, 1050, 120],
    12: [19500, 2700, 11000, 1500, 145],
  };

  static const Map<int, List<num>> _defaultCharmTable = {
    1: [10, 0, 2.5, 7000],
    2: [25, 5, 5.5, 17500],
    3: [50, 15, 9.0, 35000],
    4: [90, 30, 14.0, 63000],
    5: [150, 55, 20.5, 105000],
    6: [240, 95, 28.5, 168000],
    7: [360, 150, 38.0, 252000],
    8: [520, 230, 50.0, 364000],
    9: [720, 340, 64.5, 504000],
    10: [980, 490, 82.0, 686000],
    11: [1300, 680, 105.0, 910000],
    12: [1750, 920, 132.0, 1225000],
  };

  static const Map<String, Map<String, dynamic>> _defaultSvsRates = {
    'fc': {'name': 'Fire Crystals', 'rate': 2000, 'unit': 'FC', 'day': 'Day 1 & Day 5'},
    'rfc': {'name': 'Refined Fire Crystals', 'rate': 30000, 'unit': 'RFC', 'day': 'Day 1 & Day 5'},
    'speedup_hr': {'name': 'Speedups (Hours)', 'rate': 1800, 'unit': 'Hours', 'day': 'Day 1, 2 & 5'},
    'speedup_min': {'name': 'Speedups (Minutes)', 'rate': 30, 'unit': 'Minutes', 'day': 'Day 1, 2 & 5'},
    'fc_shard': {'name': 'FC Shards (Helios)', 'rate': 1000, 'unit': 'Shards', 'day': 'Day 2 & Day 5'},
    'lucky_wheel': {'name': 'Lucky Wheel Spins', 'rate': 4000, 'unit': 'Spins', 'day': 'Day 2'},
    'hero_shard': {'name': 'Mythic Hero Shards', 'rate': 6000, 'unit': 'Shards', 'day': 'Day 2'},
    'expert_sigil': {'name': 'Dawn Expert Sigils', 'rate': 6000, 'unit': 'Sigils', 'day': 'Day 2'},
    'polar_terror': {'name': 'Polar Terror Rallies', 'rate': 30000, 'unit': 'Rallies', 'day': 'Day 3'},
    'mithril': {'name': 'Mithril (Exclusive Gear)', 'rate': 144000, 'unit': 'Mithril', 'day': 'Day 4 & 5'},
    't10_train': {'name': 'T10 Troops Trained', 'rate': 60, 'unit': 'Troops', 'day': 'Day 4'},
    't11_train': {'name': 'T11 Troops Trained', 'rate': 75, 'unit': 'Troops', 'day': 'Day 4'},
    't12_train': {'name': 'T12 Troops Trained', 'rate': 90, 'unit': 'Troops', 'day': 'Day 4'},
  };

  static const List<Map<String, String>> _defaultGiftCodes = [
    {'code': 'WOS2026', 'rewards': '1000 Gems, 5x 1h Speedups, 10x Gold Keys, 500k Meat/Wood'},
    {'code': 'STATEOFPOWER', 'rewards': '500 Gems, 10x Advanced Wild Marks, 20x Charm Guides'},
    {'code': 'DC300K', 'rewards': '1500 Gems, 20x Mythic Shards, 10x 1h Speedups'},
    {'code': 'FROSTYTACTICS', 'rewards': 'Exclusive Frosty Avatar Frame, 300 Gems, 5x Stamina'},
    {'code': 'BEARHUNT2026', 'rewards': '800 Gems, 100x Stamina, 10x March Speedups'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF040812),
      appBar: AppBar(
        backgroundColor: const Color(0xFF070D18),
        elevation: 0,
        title: Row(
          children: [
            Text('🧮 ', style: TextStyle(fontSize: 18)),
            Text(
              context.tr('Tactical Utilities & Calculators', '戦術ユーティリティ＆計算ツール'),
              style: TextStyle(
                fontFamily: 'Outfit',
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.white,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Sub-Tab Selector
          Container(
            color: const Color(0xFF070D18),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: [
                  _buildSubTab(0, context.tr('💎 Fire Crystal', '💎 火晶'), 'FC'),
                  _buildSubTab(1, context.tr('🛡️ Chief Charms', '🛡️ 首長チャーム'), 'Charms'),
                  _buildSubTab(2, context.tr('🏆 SvS Points', '🏆 SvSポイント'), 'SvS'),
                  _buildSubTab(3, context.tr('🐻 Bear Simulator', '🐻 熊狩りシミュ'), 'Bear'),
                  _buildSubTab(4, context.tr('🚀 State Transfer', '🚀 サーバー移転'), 'Transfer'),
                  _buildSubTab(5, context.tr('🎁 Gift Codes', '🎁 ギフトコード'), 'Codes'),
                  _buildSubTab(6, context.tr('⏰ UTC Timers', '⏰ UTCタイマー'), 'Timers'),
                ],
              ),
            ),
          ),

          // Tab Content
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: _buildActiveTabContent(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubTab(int index, String label, String shortLabel) {
    final isSelected = _activeTab == index;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => setState(() => _activeTab = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            gradient: isSelected
                ? const LinearGradient(colors: [Color(0xFF00F0FF), Color(0xFF0284C7)])
                : null,
            color: isSelected ? null : const Color(0xFF0F192C),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? const Color(0xFF00F0FF) : Colors.white12,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? const Color(0xFF040914) : const Color(0xFF94A3B8),
              fontSize: 12.5,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              fontFamily: 'Outfit',
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActiveTabContent() {
    switch (_activeTab) {
      case 0:
        return _buildFCCalculator();
      case 1:
        return _buildCharmsCalculator();
      case 2:
        return _buildSvSCalculator();
      case 3:
        return _buildBearTrapSimulator();
      case 4:
        return _buildTransferCalculator();
      case 5:
        return _buildGiftCodesView();
      case 6:
        return _buildUTCTimersView();
      default:
        return const SizedBox();
    }
  }

  // --- 1. Fire Crystal Calculator ---
  Widget _buildFCCalculator() {
    final fcTable = _resolveFcTable();
    final maxFcLevel = fcTable.keys.isNotEmpty ? fcTable.keys.reduce((a, b) => a > b ? a : b) : 10;
    final isFurnace = _fcBuildingType == 'furnace';
    int totalFC = 0;
    int totalRFC = 0;
    int totalDays = 0;

    for (int lvl = _fcFromLevel + 1; lvl <= _fcToLevel; lvl++) {
      final row = fcTable[lvl] ?? [0, 0, 0, 0, 0];
      if (isFurnace) {
        totalFC += row[0].toInt();
        totalRFC += row[1].toInt();
      } else {
        totalFC += row[2].toInt();
        totalRFC += row[3].toInt();
      }
      totalDays += row[4].toInt();
    }
    final int svsPoints = (totalFC * 2000) + (totalRFC * 30000);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCard(
          title: context.tr('💎 Fire Crystal Upgrade Planner', '💎 火晶アップグレード計画'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(context.tr('Select Building Type:', '建物の種類を選択：'), style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: _buildSelectionChip(
                      label: context.tr('Furnace / Embassy / Command', '溶鉱炉 / 大使館 / 司令部'),
                      isSelected: isFurnace,
                      onTap: () => setState(() => _fcBuildingType = 'furnace'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildSelectionChip(
                      label: context.tr('Troop Camp (Inf/Lan/Mar)', '兵舎（盾/槍/弓）'),
                      isSelected: !isFurnace,
                      onTap: () => setState(() => _fcBuildingType = 'camp'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildDropdown(
                      label: context.tr('Current FC Level', '現在の火晶レベル'),
                      value: _fcFromLevel,
                      items: List.generate(maxFcLevel, (i) => i),
                      itemLabel: (val) => val == 0 ? 'Lv 30 (FC 0)' : 'FC $val',
                      onChanged: (val) {
                        if (val != null && val < _fcToLevel) setState(() => _fcFromLevel = val);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildDropdown(
                      label: context.tr('Target FC Level', '目標の火晶レベル'),
                      value: _fcToLevel,
                      items: List.generate(maxFcLevel, (i) => i + 1),
                      itemLabel: (val) => 'FC $val',
                      onChanged: (val) {
                        if (val != null && val > _fcFromLevel) setState(() => _fcToLevel = val);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildCard(
          title: context.tr('📊 Required Upgrade Materials', '📊 必要なアップグレード素材'),
          child: Column(
            children: [
              _buildResultRow(context.tr('Regular Fire Crystals (FC)', '火晶（FC）'), '$totalFC FC', const Color(0xFF00F0FF)),
              if (totalRFC > 0) ...[
                const SizedBox(height: 8),
                _buildResultRow(context.tr('Refined Fire Crystals (RFC)', '精錬火晶（RFC）'), '$totalRFC RFC', const Color(0xFFA855F7)),
              ],
              const SizedBox(height: 8),
              _buildResultRow(context.tr('Base Construction Time', '基本建設時間'), context.tr('~$totalDays Days', '約$totalDays日'), const Color(0xFFF59E0B)),
              const SizedBox(height: 8),
              _buildResultRow(context.tr('SvS City Construction Points', 'SvS 都市建設ポイント'), '${_formatNumber(svsPoints)} pt', const Color(0xFF10B981)),
            ],
          ),
        ),
      ],
    );
  }

  // --- 2. Chief Charms Calculator ---
  Widget _buildCharmsCalculator() {
    final charmTable = _resolveCharmTable();
    final maxCharmLevel = charmTable.keys.isNotEmpty ? charmTable.keys.reduce((a, b) => a > b ? a : b) : 11;
    int totalGuides = 0;
    int totalDesigns = 0;
    double totalBoost = 0;
    int totalSvS = 0;

    for (int lvl = _charmFromLevel + 1; lvl <= _charmToLevel; lvl++) {
      final row = charmTable[lvl] ?? [0, 0, 0.0, 0];
      totalGuides += row[0].toInt();
      totalDesigns += row[1].toInt();
      totalBoost += row[2].toDouble();
      totalSvS += row[3].toInt();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCard(
          title: context.tr('🛡️ Chief Charms Upgrade Planner (Per Slot)', '🛡️ 首長チャーム強化計画（1枠あたり）'),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildDropdown(
                      label: context.tr('Current Charm Level', '現在のチャームレベル'),
                      value: _charmFromLevel,
                      items: List.generate(maxCharmLevel, (i) => i),
                      itemLabel: (val) => val == 0 ? context.tr('Unequipped (Lv 0)', '未装備（Lv 0）') : 'Lv $val',
                      onChanged: (val) {
                        if (val != null && val < _charmToLevel) setState(() => _charmFromLevel = val);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildDropdown(
                      label: context.tr('Target Charm Level', '目標のチャームレベル'),
                      value: _charmToLevel,
                      items: List.generate(maxCharmLevel, (i) => i + 1),
                      itemLabel: (val) => 'Lv $val',
                      onChanged: (val) {
                        if (val != null && val > _charmFromLevel) setState(() => _charmToLevel = val);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildCard(
          title: context.tr('📊 Required Materials & Combat Stats', '📊 必要素材＆戦闘ステータス'),
          child: Column(
            children: [
              _buildResultRow(context.tr('Charm Guides Needed', '必要なチャームガイド'), context.tr('$totalGuides Guides', '$totalGuides 個'), const Color(0xFF00F0FF)),
              const SizedBox(height: 8),
              _buildResultRow(context.tr('Charm Designs Needed', '必要なチャーム設計図'), context.tr('$totalDesigns Designs', '$totalDesigns 個'), const Color(0xFFA855F7)),
              const SizedBox(height: 8),
              _buildResultRow(context.tr('Lethality / Health Surge', '殺傷力 / HP 上昇'), '+${totalBoost.toStringAsFixed(1)}%', const Color(0xFFF59E0B)),
              const SizedBox(height: 8),
              _buildResultRow(context.tr('SvS Charm Points (70 pts/score)', 'SvS チャームポイント（70pt/スコア）'), '${_formatNumber(totalSvS)} pt', const Color(0xFF10B981)),
            ],
          ),
        ),
      ],
    );
  }

  // --- 3. SvS Points Calculator ---
  Widget _buildSvSCalculator() {
    final svsRates = _resolveSvsRates();
    if (!svsRates.containsKey(_svsActivity)) {
      _svsActivity = svsRates.keys.first;
    }
    final selectedRate = svsRates[_svsActivity]!;
    final int amount = int.tryParse(_svsAmountController.text.trim()) ?? 0;
    final int totalPoints = amount * (selectedRate['rate'] as int);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCard(
          title: context.tr('🏆 SvS Prep Phase Points Calculator', '🏆 SvS準備期間ポイント計算'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(context.tr('Select Activity:', 'アクティビティを選択：'), style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFF132238),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF38BDF8).withOpacity(0.3)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _svsActivity,
                    isExpanded: true,
                    dropdownColor: const Color(0xFF0F192C),
                    items: svsRates.entries.map((e) {
                      return DropdownMenuItem<String>(
                        value: e.key,
                        child: Text(e.value['name'] as String, style: const TextStyle(color: Colors.white)),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _svsActivity = val);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(context.tr('Enter Quantity:', '数量を入力：'), style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
              const SizedBox(height: 6),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF132238),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF38BDF8).withOpacity(0.3)),
                ),
                child: TextField(
                  controller: _svsAmountController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    suffixText: selectedRate['unit'] as String,
                    suffixStyle: const TextStyle(color: Color(0xFF00F0FF)),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildCard(
          title: context.tr('🌟 Point Conversion Result', '🌟 ポイント換算結果'),
          child: Column(
            children: [
              _buildResultRow(context.tr('Total SvS Points Earned', '獲得SvSポイント合計'), '${_formatNumber(totalPoints)} pt', const Color(0xFF10B981)),
              const SizedBox(height: 8),
              _buildResultRow(context.tr('Optimal Day to Spend', '使用に最適な日'), selectedRate['day'] as String, const Color(0xFFF59E0B)),
            ],
          ),
        ),
      ],
    );
  }

  // --- 4. Bear Trap Damage Simulator ---
  Widget _buildBearTrapSimulator() {
    final int capacity = int.tryParse(_bearMarchCapacityController.text.trim()) ?? 150000;

    // Tier base damage multipliers
    final Map<String, double> tierMultipliers = {
      'T8': 1.0,
      'T9': 1.35,
      'T10': 1.85,
      'T11': 2.45,
      'T12': 3.20,
    };
    final double tierMult = tierMultipliers[_bearTroopTier] ?? 1.85;

    // Ratio distribution & DPS multipliers
    double infPct = 0.10;
    double lanPct = 0.10;
    double mrkPct = 0.80;
    double ratioEfficiency = 1.95;

    if (_bearRatioPreset == '0/20/80') {
      infPct = 0.0;
      lanPct = 0.20;
      mrkPct = 0.80;
      ratioEfficiency = 1.90;
    } else if (_bearRatioPreset == '33/33/33') {
      infPct = 0.334;
      lanPct = 0.333;
      mrkPct = 0.333;
      ratioEfficiency = 1.00;
    }

    final int infCount = (capacity * infPct).round();
    final int lanCount = (capacity * lanPct).round();
    final int mrkCount = capacity - infCount - lanCount;

    // Joiner buff (+25% per Jessie / Seo-yoon / Jader up to 4 stacks = +100%)
    final double joinerBonusPct = _bearJoinerJessieCount * 25.0;
    final double joinerMultiplier = 1.0 + (joinerBonusPct / 100.0);

    // Total Tactical Efficiency Score
    final double totalMultiplier = tierMult * ratioEfficiency * joinerMultiplier;
    final double dpsGainOverDefault = ((totalMultiplier / (tierMult * 1.0 * 1.0)) - 1.0) * 100.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCard(
          title: context.tr('🐻 Bear Trap Rally Configuration', '🐻 熊狩り集結設定'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(context.tr('March Capacity (Single Rally / Lead):', '行軍容量（単独集結 / 主催）：'), style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
              const SizedBox(height: 6),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF132238),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF38BDF8).withOpacity(0.3)),
                ),
                child: TextField(
                  controller: _bearMarchCapacityController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    suffixText: context.tr('Troops', '兵'),
                    suffixStyle: TextStyle(color: Color(0xFF00F0FF)),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(height: 10),
              // Quick Capacity Chips
              Wrap(
                spacing: 8,
                children: [100000, 130000, 160000, 200000].map((c) {
                  return ActionChip(
                    label: Text('${c ~/ 1000}k'),
                    labelStyle: const TextStyle(fontSize: 11, color: Colors.white70),
                    backgroundColor: const Color(0xFF0F192C),
                    side: const BorderSide(color: Colors.white24),
                    onPressed: () {
                      _bearMarchCapacityController.text = c.toString();
                      setState(() {});
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Troop Tier Picker & Ratio Preset
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(context.tr('Troop Tier:', '兵士ランク：'), style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF132238),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFF38BDF8).withOpacity(0.3)),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _bearTroopTier,
                              isExpanded: true,
                              dropdownColor: const Color(0xFF0F192C),
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              items: ['T8', 'T9', 'T10', 'T11', 'T12'].map((t) {
                                return DropdownMenuItem(value: t, child: Text(t));
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) setState(() => _bearTroopTier = val);
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(context.tr('Troop Ratio:', '兵種比率：'), style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF132238),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFF38BDF8).withOpacity(0.3)),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _bearRatioPreset,
                              isExpanded: true,
                              dropdownColor: const Color(0xFF0F192C),
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                              items: [
                                DropdownMenuItem(value: '10/10/80', child: Text(context.tr('10/10/80 (Meta)', '10/10/80（メタ）'))),
                                DropdownMenuItem(value: '0/20/80', child: Text(context.tr('0/20/80 (Marksman)', '0/20/80（弓兵）'))),
                                DropdownMenuItem(value: '33/33/33', child: Text(context.tr('33/33/33 (Default)', '33/33/33（デフォルト）'))),
                              ],
                              onChanged: (val) {
                                if (val != null) setState(() => _bearRatioPreset = val);
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Joiner Jessie/Buff Count Slider/Counter
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(context.tr('Top Joiners with Jessie / Buffs (+25% each):', 'ジェシー等バフ持ちの上位参加者（各+25%）：'), style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                      Text(context.tr('$_bearJoinerJessieCount Joiners (+${joinerBonusPct.toInt()}% Total Skill Buff)', '参加者$_bearJoinerJessieCount人（スキルバフ合計 +${joinerBonusPct.toInt()}%）'),
                          style: const TextStyle(color: Color(0xFF00F0FF), fontSize: 13, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline, color: Color(0xFF38BDF8)),
                        onPressed: _bearJoinerJessieCount > 0
                            ? () => setState(() => _bearJoinerJessieCount--)
                            : null,
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline, color: Color(0xFF00F0FF)),
                        onPressed: _bearJoinerJessieCount < 4
                            ? () => setState(() => _bearJoinerJessieCount++)
                            : null,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Simulation Results Card
        _buildCard(
          title: context.tr('📊 Tactical Damage Output Simulation', '📊 戦術ダメージ出力シミュレーション'),
          child: Column(
            children: [
              _buildResultRow(context.tr('Overall Damage Multiplier', '総合ダメージ倍率'), context.tr('${totalMultiplier.toStringAsFixed(2)}x Boost', '${totalMultiplier.toStringAsFixed(2)}倍'), const Color(0xFF00F0FF)),
              const SizedBox(height: 8),
              _buildResultRow(context.tr('DPS Surge Over Standard', '標準比のDPS上昇'), context.tr('+${dpsGainOverDefault.toStringAsFixed(0)}% Damage', 'ダメージ +${dpsGainOverDefault.toStringAsFixed(0)}%'), const Color(0xFF10B981)),
              const SizedBox(height: 12),
              const Divider(color: Colors.white12),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(context.tr('🏹 Recommended March Troop Breakdown:', '🏹 推奨行軍兵士内訳：'),
                    style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _buildTroopBox(context.tr('🛡️ Infantry', '🛡️ 盾兵'), '${_formatNumber(infCount)} (${(infPct * 100).toInt()}%)', const Color(0xFF38BDF8)),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildTroopBox(context.tr('🐎 Lancer', '🐎 槍兵'), '${_formatNumber(lanCount)} (${(lanPct * 100).toInt()}%)', const Color(0xFFF59E0B)),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildTroopBox(context.tr('🏹 Marksman', '🏹 弓兵'), '${_formatNumber(mrkCount)} (${(mrkPct * 100).toInt()}%)', const Color(0xFFEF4444)),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Strategy Tips Card
        _buildCard(
          title: context.tr('💡 Bear Trap Master Strategy', '💡 熊狩りマスター戦略'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(context.tr('• Marksmen deal ~2.2x higher damage than Infantry vs Bear Trap because the Bear deals zero lethal return damage.', '• 熊は致命的な反撃をしないため、熊狩りでは弓兵が盾兵の約2.2倍のダメージを与えます。'),
                  style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12, height: 1.4)),
              SizedBox(height: 6),
              Text(context.tr('• Top 4 Rally Joiners MUST send Jessie (+25%), Jader (+25%), or Seo-yoon (+20%) as their 1st Hero for maximum damage stacking.', '• 上位4人の集結参加者は、ダメージを最大化するため必ずジェシー（+25%）、ジェイダー（+25%）、ソユン（+20%）を第1英雄にしてください。'),
                  style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12, height: 1.4)),
              SizedBox(height: 6),
              Text(context.tr('• Use March Speedups to quickly return marches and re-join multiple active alliance rallies.', '• 行軍加速を使って素早く帰還し、複数の同盟集結に再参加しましょう。'),
                  style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12, height: 1.4)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTroopBox(String label, String count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF132238),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Column(
        children: [
          Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(count, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // --- 5. State Transfer Calculator ---
  Widget _buildTransferCalculator() {
    final double power = double.tryParse(_transferPowerController.text.trim()) ?? 150.0;
    int passes = 1;
    String tier = context.tr('Ordinary Transfer', '一般移転');

    if (power < 30) {
      passes = 1;
    } else if (power < 50) {
      passes = 2;
    } else if (power < 75) {
      passes = 3;
    } else if (power < 100) {
      passes = 5;
    } else if (power < 130) {
      passes = 8;
    } else if (power < 170) {
      passes = 12;
    } else if (power < 220) {
      passes = 18;
    } else if (power < 280) {
      passes = 25;
    } else if (power < 350) {
      passes = 35;
      tier = context.tr('High Power Transfer', '高戦力移転');
    } else if (power < 450) {
      passes = 50;
      tier = context.tr('High Power Transfer', '高戦力移転');
    } else if (power < 600) {
      passes = 65;
      tier = context.tr('Top Tier Transfer', 'トップ層移転');
    } else {
      passes = 80;
      tier = context.tr('Whale Transfer (Requires Leading Invite)', '重課金移転（招待枠が必要）');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCard(
          title: context.tr('🚀 State Transfer Pass Calculator', '🚀 サーバー移転パス計算'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(context.tr('Enter Chief Power (in Millions):', '首長の戦力を入力（百万単位）：'), style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
              const SizedBox(height: 6),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF132238),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF38BDF8).withOpacity(0.3)),
                ),
                child: TextField(
                  controller: _transferPowerController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    suffixText: context.tr('Million Power', '百万戦力'),
                    suffixStyle: TextStyle(color: Color(0xFF00F0FF)),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildCard(
          title: context.tr('🎫 Transfer Pass Requirement', '🎫 必要な移転パス'),
          child: Column(
            children: [
              _buildResultRow(context.tr('Required Transfer Passes', '必要な移転パス数'), context.tr('$passes Passes', '$passes 枚'), const Color(0xFF00F0FF)),
              const SizedBox(height: 8),
              _buildResultRow(context.tr('Transfer Category', '移転カテゴリ'), tier, const Color(0xFFF59E0B)),
              const SizedBox(height: 14),
              const Divider(height: 1, color: Colors.white12),
              const SizedBox(height: 12),
              Text(
                context.tr('• Furnace Lv 25 minimum\n• Empty infirmary & no active marches\n• 30-Day transfer cooldown between hops\n• Target state must have open ordinary/leading quota', '• 溶鉱炉Lv25以上\n• 病院が空で行軍中の部隊がないこと\n• 移転ごとに30日のクールダウン\n• 移転先サーバーに一般/招待枠の空きが必要'),
                style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12, height: 1.4),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- 5. Gift Codes ---
  Widget _buildGiftCodesView() {
    final giftCodes = _resolveGiftCodes();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCard(
          title: context.tr('🎁 Active Whiteout Survival Promo Codes', '🎁 有効なホワイトアウト・サバイバル ギフトコード'),
          child: Column(
            children: giftCodes.map((c) {
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF132238),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF10B981).withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            c['code']!,
                            style: const TextStyle(
                              color: Color(0xFF10B981),
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Outfit',
                              letterSpacing: 1.1,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            c['rewards']!,
                            style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11.5),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy_rounded, color: Color(0xFF00F0FF), size: 20),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: c['code']!));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(context.tr('Copied code: ${c['code']}', 'コードをコピーしました: ${c['code']}')),
                            backgroundColor: const Color(0xFF0284C7),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: () async {
            final url = Uri.parse('https://wos-giftcode.centurygame.com/');
            if (await canLaunchUrl(url)) {
              await launchUrl(url, mode: LaunchMode.externalApplication);
            }
          },
          icon: const Icon(Icons.open_in_browser_rounded),
          label: Text(context.tr('Open Official Century Games Redeem Portal', 'Century Games公式引き換えページを開く'), style: TextStyle(fontWeight: FontWeight.bold)),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00F0FF),
            foregroundColor: const Color(0xFF040914),
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
      ],
    );
  }

  // --- 6. UTC Alliance Timers ---
  Widget _buildUTCTimersView() {
    final nowUtc = DateTime.now().toUtc();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCard(
          title: context.tr('⏰ Alliance UTC Battle Windows', '⏰ 同盟イベント時間（UTC）'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${context.tr('Current UTC Time', '現在のUTC時刻')}: ${nowUtc.hour.toString().padLeft(2, '0')}:${nowUtc.minute.toString().padLeft(2, '0')} UTC',
                style: const TextStyle(color: Color(0xFF00F0FF), fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 14),
              _buildTimerRow(context.tr('Foundry Battle', '兵器工場争奪戦'), context.tr('19:00 & 21:00 UTC (Sat/Sun)', '19:00 & 21:00 UTC（土/日）')),
              const SizedBox(height: 8),
              _buildTimerRow(context.tr('Canyon Clash', '峡谷合戦'), context.tr('12:00 & 19:00 UTC (Bi-weekly)', '12:00 & 19:00 UTC（隔週）')),
              const SizedBox(height: 8),
              _buildTimerRow(context.tr('SVS Battle Phase', 'SvS 戦闘フェーズ'), context.tr('10:00 – 22:00 UTC (Saturday)', '10:00 – 22:00 UTC（土曜）')),
              const SizedBox(height: 8),
              _buildTimerRow(context.tr('Bear Trap', '熊狩り'), context.tr('Every 48 Hours (Alliance set)', '48時間ごと（同盟設定）')),
              const SizedBox(height: 8),
              _buildTimerRow(context.tr('Fortress Battle', '要塞争奪戦'), context.tr('14:00 & 19:00 UTC (Alternating)', '14:00 & 19:00 UTC（交互）')),
            ],
          ),
        ),
      ],
    );
  }

  // --- UI Helpers ---
  Widget _buildCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF0F192C).withOpacity(0.9),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF00F0FF).withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold, fontFamily: 'Outfit'),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _buildResultRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13)),
        Text(value, style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.bold, fontFamily: 'Outfit')),
      ],
    );
  }

  Widget _buildTimerRow(String event, String time) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF132238),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(event, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          Text(time, style: const TextStyle(color: Color(0xFF38BDF8), fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildSelectionChip({required String label, required bool isSelected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF00F0FF).withOpacity(0.15) : const Color(0xFF132238),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isSelected ? const Color(0xFF00F0FF) : Colors.white12),
        ),
        child: Center(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? const Color(0xFF00F0FF) : const Color(0xFF94A3B8),
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required T value,
    required List<T> items,
    required String Function(T) itemLabel,
    required ValueChanged<T?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF132238),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFF38BDF8).withOpacity(0.3)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              isExpanded: true,
              dropdownColor: const Color(0xFF0F192C),
              items: items.map((item) {
                return DropdownMenuItem<T>(
                  value: item,
                  child: Text(itemLabel(item), style: const TextStyle(color: Colors.white, fontSize: 12.5)),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000000) {
      return '${(number / 1000000000).toStringAsFixed(2)}B';
    } else if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(2)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}k';
    }
    return number.toString();
  }
}
