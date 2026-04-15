import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MyWidget extends StatefulWidget {
  const MyWidget({super.key});

  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  // Controllers
  final TextEditingController _accountController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();
  final TextEditingController _volumeController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  // FocusNodes
  final FocusNode _accountFocus = FocusNode();
  final FocusNode _stockFocus = FocusNode();
  final FocusNode _volumeFocus = FocusNode();
  final FocusNode _priceFocus = FocusNode();

  // Error texts
  String? _accountError;
  String? _stockError;
  String? _volumeError;
  String? _priceError;

  // Field đang focus (cập nhật khi user tap hoặc khi keyboard nav move focus).
  // Dùng để biết field NÀO cần validate khi user tap sang field khác.
  FocusNode? _lastFocusedField;

  // Flag: đang trong quá trình validate async (tránh duplicate call)
  bool _isValidating = false;

  // ==========================================================================
  // POINTER-BASED FOCUS CHANGE
  // Chỉ fire khi user TAP CHUỘT vào TextField. Keyboard nav KHÔNG trigger onTap.
  // Job: validate field trước đó, hiện error, KHÔNG đụng focus (user đã click
  // sang field mới — không được "giật" focus ngược lại).
  // ==========================================================================
  Future<void> _onPointerFocusChange(FocusNode tappedFocus) async {
    final prev = _lastFocusedField;
    _lastFocusedField = tappedFocus;

    if (prev == null || prev == tappedFocus) return;
    if (_isValidating) return;

    final (controller, validator) = _fieldOf(prev);

    _isValidating = true;
    final error = await validator(controller.text);
    _isValidating = false;

    if (!mounted) return;
    setState(() => _setError(prev, error));
  }

  // Lookup controller + validator theo FocusNode
  (TextEditingController, Future<String?> Function(String)) _fieldOf(
    FocusNode focus,
  ) {
    if (focus == _accountFocus) return (_accountController, _validateAccount);
    if (focus == _stockFocus) return (_stockController, _validateStock);
    if (focus == _volumeFocus) return (_volumeController, _validateVolume);
    return (_priceController, _validatePrice);
  }

  // Gán error cho đúng field dựa vào focusNode
  void _setError(FocusNode focusNode, String? error) {
    if (focusNode == _accountFocus)
      _accountError = error;
    else if (focusNode == _stockFocus)
      _stockError = error;
    else if (focusNode == _volumeFocus)
      _volumeError = error;
    else if (focusNode == _priceFocus)
      _priceError = error;
  }

  // Xử lý keyboard events (Enter, Tab, Shift+Tab, Arrow)
  KeyEventResult _handleKeyEvent(
    FocusNode currentFocus,
    TextEditingController controller,
    Future<String?> Function(String) validator,
    FocusNode? prevFocus,
    FocusNode? nextFocus,
    KeyEvent event,
  ) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }

    final isEnter = event.logicalKey == LogicalKeyboardKey.enter;
    final isTab = event.logicalKey == LogicalKeyboardKey.tab;
    final isArrowRight = event.logicalKey == LogicalKeyboardKey.arrowRight;
    final isArrowLeft = event.logicalKey == LogicalKeyboardKey.arrowLeft;
    final isShiftPressed = HardwareKeyboard.instance.isShiftPressed;

    final shouldMoveNext =
        isEnter || isArrowRight || (isTab && !isShiftPressed);
    final shouldMovePrev = isArrowLeft || (isTab && isShiftPressed);

    if (!shouldMoveNext && !shouldMovePrev) {
      return KeyEventResult.ignored;
    }

    _handleKeyNavigation(
      controller: controller,
      validator: validator,
      currentFocus: currentFocus,
      targetFocus: shouldMoveNext ? nextFocus : prevFocus,
      shouldMoveNext: shouldMoveNext,
    );

    return KeyEventResult.handled;
  }

  Future<void> _handleKeyNavigation({
    required TextEditingController controller,
    required Future<String?> Function(String) validator,
    required FocusNode currentFocus,
    required FocusNode? targetFocus,
    required bool shouldMoveNext,
  }) async {
    if (_isValidating) return;

    _isValidating = true;
    final error = await validator(controller.text);
    _isValidating = false;

    if (!mounted) return;

    setState(() {
      _setError(currentFocus, error);
    });

    if (error == null && targetFocus != null) {
      // Pass → move focus sang field tiếp/trước
      _lastFocusedField = targetFocus;
      targetFocus.requestFocus();
    } else {
      // Fail (hoặc không có target) → giữ focus
      _lastFocusedField = currentFocus;
      currentFocus.requestFocus();
    }
  }

  // ---- Validators (có async/API call) ----

  Future<String?> _validateAccount(String value) async {
    if (value.isEmpty) return 'Account không được để trống';
    // await apiService.validateAccount(value);
    await Future.delayed(Duration(milliseconds: 300)); // simulate API
    print('_validateAccount');
    return null; // null = không có lỗi
  }

  Future<String?> _validateStock(String value) async {
    if (value.isEmpty) return 'Stock không được để trống';
    await Future.delayed(Duration(milliseconds: 300));
    print('_validateStock');

    return null;
  }

  Future<String?> _validateVolume(String value) async {
    if (value.isEmpty) return 'Volume không được để trống';
    if (int.tryParse(value) == null) return 'Volume phải là số';
    print('_validateVolume');

    return null;
  }

  Future<String?> _validatePrice(String value) async {
    if (value.isEmpty) return 'Price không được để trống';
    if (double.tryParse(value) == null) return 'Price phải là số';
    print('_validatePrice');

    return null;
  }

  // ---- Build ----

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
        child: Column(
          children: [
            _buildField(
              label: 'Account',
              controller: _accountController,
              focusNode: _accountFocus,
              error: _accountError,
              validator: _validateAccount,
              prevFocus: null,
              nextFocus: _stockFocus,
            ),
            _buildField(
              label: 'Stock',
              controller: _stockController,
              focusNode: _stockFocus,
              error: _stockError,
              validator: _validateStock,
              prevFocus: _accountFocus,
              nextFocus: _volumeFocus,
            ),
            _buildField(
              label: 'Volume',
              controller: _volumeController,
              focusNode: _volumeFocus,
              error: _volumeError,
              validator: _validateVolume,
              prevFocus: _stockFocus,
              nextFocus: _priceFocus,
            ),
            _buildField(
              label: 'Price',
              controller: _priceController,
              focusNode: _priceFocus,
              error: _priceError,
              validator: _validatePrice,
              prevFocus: _volumeFocus,
              nextFocus: null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required FocusNode focusNode,
    required String? error,
    required Future<String?> Function(String) validator,
    required FocusNode? prevFocus,
    required FocusNode? nextFocus,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Focus(
          onKeyEvent: (node, event) {
            final result = _handleKeyEvent(
              focusNode,
              controller,
              validator,
              prevFocus,
              nextFocus,
              event,
            );
            return result; // trả về KeyEventResult.handled để chặn bubble
          },
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            onTap: () => _onPointerFocusChange(focusNode),
            decoration: InputDecoration(labelText: label),
          ),
        ),
        if (error != null)
          Text(error, style: TextStyle(color: Colors.red, fontSize: 12)),
      ],
    );
  }

  @override
  void dispose() {
    _accountController.dispose();
    _stockController.dispose();
    _volumeController.dispose();
    _priceController.dispose();
    _accountFocus.dispose();
    _stockFocus.dispose();
    _volumeFocus.dispose();
    _priceFocus.dispose();
    super.dispose();
  }
}
