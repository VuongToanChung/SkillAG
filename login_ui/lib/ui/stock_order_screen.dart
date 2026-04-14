import 'dart:math';

import 'package:flutter/material.dart';

class StockOrderScreen extends StatefulWidget {
  const StockOrderScreen({super.key});

  @override
  State<StockOrderScreen> createState() => _StockOrderScreenState();
}

class _StockOrderScreenState extends State<StockOrderScreen> {
  // ── Controllers ──────────────────────────────────────────────────────
  late final TextEditingController _accountController;
  late final TextEditingController _stockController;
  late final TextEditingController _volumeController;
  late final TextEditingController _priceController;

  // ── Focus Nodes ──────────────────────────────────────────────────────
  late final FocusNode _accountFocusNode;
  late final FocusNode _stockFocusNode;
  late final FocusNode _volumeFocusNode;
  late final FocusNode _priceFocusNode;

  // ── State ────────────────────────────────────────────────────────────
  bool _isOrderEnabled = false;
  bool _isAccountEnabled = true;
  bool _isStockEnabled = true;
  bool _isVolumeEnabled = true;
  bool _isPriceEnabled = true;

  // ── Random data generators ───────────────────────────────────────────
  final _random = Random();

  final List<String> _sampleAccounts = [
    '066C123456',
    '021C789012',
    '088C345678',
    '015C901234',
    '079C567890',
  ];

  final List<String> _sampleStocks = [
    'VNM',
    'VIC',
    'VHM',
    'HPG',
    'FPT',
    'MWG',
    'VCB',
    'TCB',
    'SSI',
    'VND',
  ];

  @override
  void initState() {
    super.initState();

    _accountController = TextEditingController();
    _stockController = TextEditingController();
    _volumeController = TextEditingController();
    _priceController = TextEditingController();

    _accountFocusNode = FocusNode();
    _stockFocusNode = FocusNode();
    _volumeFocusNode = FocusNode();
    _priceFocusNode = FocusNode();

    // Listen to text changes to validate Order button state
    _accountController.addListener(_validateOrderButton);
    _stockController.addListener(_validateOrderButton);
    _volumeController.addListener(_validateOrderButton);
    _priceController.addListener(_validateOrderButton);
  }

  @override
  void dispose() {
    _accountController.dispose();
    _stockController.dispose();
    _volumeController.dispose();
    _priceController.dispose();

    _accountFocusNode.dispose();
    _stockFocusNode.dispose();
    _volumeFocusNode.dispose();
    _priceFocusNode.dispose();

    super.dispose();
  }

  // ── Validate Order Button ────────────────────────────────────────────
  void _validateOrderButton() {
    final allFilled = _accountController.text.isNotEmpty &&
        _stockController.text.isNotEmpty &&
        _volumeController.text.isNotEmpty &&
        _priceController.text.isNotEmpty;

    if (_isOrderEnabled != allFilled) {
      setState(() {
        _isOrderEnabled = allFilled;
      });
    }
  }

  // ── Helper: unfocus all fields first ─────────────────────────────────
  void _unfocusAll() {
    _accountFocusNode.unfocus();
    _stockFocusNode.unfocus();
    _volumeFocusNode.unfocus();
    _priceFocusNode.unfocus();
  }

  // ── Helper: fill random data ─────────────────────────────────────────
  void _fillRandomData() {
    _accountController.text =
        _sampleAccounts[_random.nextInt(_sampleAccounts.length)];
    _stockController.text =
        _sampleStocks[_random.nextInt(_sampleStocks.length)];
    _volumeController.text = '${(_random.nextInt(100) + 1) * 100}'; // 100‑10000
    _priceController.text =
        '${(_random.nextDouble() * 150 + 10).toStringAsFixed(1)}'; // 10.0‑160.0
  }

  // ── Action: Quick Buy ────────────────────────────────────────────────
  void _onQuickBuy() {
    _unfocusAll();
    setState(() {
      _isAccountEnabled = true;
      _isStockEnabled = true;
      _isVolumeEnabled = true;
      _isPriceEnabled = true;
    });

    _fillRandomData();

    // Use post‑frame callback to ensure focus request happens after rebuild
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _priceFocusNode.requestFocus();
    });
  }

  // ── Action: Cancel Order ─────────────────────────────────────────────
  void _onCancelOrder() {
    _unfocusAll();

    _fillRandomData();

    setState(() {
      _isAccountEnabled = false;
      _isStockEnabled = false;
      _isVolumeEnabled = false;
      _isPriceEnabled = false;
      _isOrderEnabled = true; // force enable Order
    });
  }

  // ── Action: Edit Order ───────────────────────────────────────────────
  void _onEditOrder() {
    _unfocusAll();
    setState(() {
      _isAccountEnabled = false;
      _isStockEnabled = false;
      _isVolumeEnabled = true;
      _isPriceEnabled = true;
    });

    _fillRandomData();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _volumeFocusNode.requestFocus();
    });
  }

  // ── Action: Sell ─────────────────────────────────────────────────────
  void _onSell() {
    _unfocusAll();
    setState(() {
      _isAccountEnabled = true;
      _isStockEnabled = true;
      _isVolumeEnabled = true;
      _isPriceEnabled = true;
      _isOrderEnabled = false;
    });

    _accountController.clear();
    _stockController.clear();
    _volumeController.clear();
    _priceController.clear();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _accountFocusNode.requestFocus();
    });
  }

  // ── Action: Order ────────────────────────────────────────────────────
  void _onOrder() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Order placed: ${_stockController.text} × ${_volumeController.text} @ ${_priceController.text}',
        ),
        backgroundColor: const Color(0xFF00C853),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // BUILD
  // ═══════════════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0822),
      appBar: AppBar(
        backgroundColor: const Color(0xFF160D30),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'STOCK ORDER',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            letterSpacing: 2,
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white70),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            children: [
              // ── Action Buttons Row ───────────────────────────────────
              _buildActionButtons(),
              const SizedBox(height: 32),

              // ── Text Fields ──────────────────────────────────────────
              _buildTextField(
                label: 'Account',
                controller: _accountController,
                focusNode: _accountFocusNode,
                enabled: _isAccountEnabled,
                icon: Icons.account_balance_wallet_outlined,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                label: 'Stock',
                controller: _stockController,
                focusNode: _stockFocusNode,
                enabled: _isStockEnabled,
                icon: Icons.candlestick_chart_outlined,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                label: 'Volume',
                controller: _volumeController,
                focusNode: _volumeFocusNode,
                enabled: _isVolumeEnabled,
                icon: Icons.bar_chart_rounded,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                label: 'Price',
                controller: _priceController,
                focusNode: _priceFocusNode,
                enabled: _isPriceEnabled,
                icon: Icons.attach_money_rounded,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 32),

              // ── Order Button ─────────────────────────────────────────
              _buildOrderButton(),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // WIDGETS
  // ═══════════════════════════════════════════════════════════════════════

  Widget _buildActionButtons() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: [
        _ActionChip(
          label: 'Quick Buy',
          icon: Icons.flash_on_rounded,
          gradient: const [Color(0xFF00C853), Color(0xFF00E676)],
          onTap: _onQuickBuy,
        ),
        _ActionChip(
          label: 'Cancel Order',
          icon: Icons.cancel_outlined,
          gradient: const [Color(0xFFFF1744), Color(0xFFFF5252)],
          onTap: _onCancelOrder,
        ),
        _ActionChip(
          label: 'Edit Order',
          icon: Icons.edit_note_rounded,
          gradient: const [Color(0xFFFF9100), Color(0xFFFFAB40)],
          onTap: _onEditOrder,
        ),
        _ActionChip(
          label: 'Sell',
          icon: Icons.trending_down_rounded,
          gradient: const [Color(0xFF651FFF), Color(0xFF7C4DFF)],
          onTap: _onSell,
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required FocusNode focusNode,
    required bool enabled,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 250),
      opacity: enabled ? 1.0 : 0.55,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        enabled: enabled,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.white, fontSize: 16),
        cursorColor: const Color(0xFF8B4EF5),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: enabled ? Colors.white60 : Colors.white30,
            fontWeight: FontWeight.w600,
          ),
          floatingLabelStyle: TextStyle(
            color: enabled ? const Color(0xFF8B4EF5) : Colors.white30,
            fontWeight: FontWeight.w700,
          ),
          prefixIcon: Icon(
            icon,
            color: enabled ? const Color(0xFF8B4EF5) : Colors.white30,
          ),
          filled: true,
          fillColor: const Color(0xFF1D123A),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFF2D1F52), width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFF8B4EF5), width: 2),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFF1A1030), width: 1),
          ),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        ),
      ),
    );
  }

  Widget _buildOrderButton() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: _isOrderEnabled
            ? const LinearGradient(
                colors: [Color(0xFF5D24AA), Color(0xFF3860A3)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              )
            : null,
        color: _isOrderEnabled ? null : const Color(0xFF1A1030),
      ),
      child: MaterialButton(
        onPressed: _isOrderEnabled ? _onOrder : null,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: Text(
          'ORDER',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: _isOrderEnabled ? Colors.white : Colors.white24,
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Action Chip Widget
// ═══════════════════════════════════════════════════════════════════════════
class _ActionChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final List<Color> gradient;
  final VoidCallback onTap;

  const _ActionChip({
    required this.label,
    required this.icon,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: gradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: gradient.first.withOpacity(0.35),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  letterSpacing: 0.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
