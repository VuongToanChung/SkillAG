import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'field_validation_cubit.dart';
import 'models.dart';
import 'select_account_cubit.dart';

enum FormMode {
  normal, // tự nhập
  edit, // Sửa: account+stock readOnly, volume+price editable
  cancel, // Hủy: tất cả readOnly
}

class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AccountCubit()),
        // SelectAccountCubit phụ thuộc AccountCubit → phải ở sau
        BlocProvider(
          create: (ctx) => SelectAccountCubit(ctx.read<AccountCubit>()),
        ),
        BlocProvider(create: (_) => StockCubit()),
        BlocProvider(create: (_) => VolumeCubit()),
        BlocProvider(create: (_) => PriceCubit()),
      ],
      child: const _StockOrderView(),
    );
  }
}

class _StockOrderView extends StatefulWidget {
  const _StockOrderView();

  @override
  State<_StockOrderView> createState() => _StockOrderViewState();
}

class _StockOrderViewState extends State<_StockOrderView> {
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

  // Models nhận về khi validate pass (từ cubit stream)
  AccountModel? _accountModel;
  StockModel? _stockModel;
  VolumeModel? _volumeModel;
  PriceModel? _priceModel;

  // Field đang focus (cập nhật khi user tap hoặc khi keyboard nav move focus).
  FocusNode? _lastFocusedField;

  // Flag: đang trong quá trình validate async (tránh duplicate call)
  bool _isValidating = false;

  // Mode hiện tại của form (normal / edit / cancel)
  FormMode _mode = FormMode.normal;

  bool _isReadOnly(FocusNode focus) {
    if (_mode == FormMode.cancel) return true;
    if (_mode == FormMode.edit) {
      return focus == _accountFocus || focus == _stockFocus;
    }
    return false;
  }

  // ==========================================================================
  // POINTER-BASED FOCUS CHANGE
  // Chỉ fire khi user TAP CHUỘT vào TextField. Keyboard nav KHÔNG trigger onTap.
  // Validate field trước đó. Nếu fail → snap focus back về field cũ.
  // ==========================================================================
  Future<void> _onPointerFocusChange(FocusNode tappedFocus) async {
    final prev = _lastFocusedField;

    if (prev == null || prev == tappedFocus) {
      _lastFocusedField = tappedFocus;
      return;
    }
    if (_isValidating) return;

    final (controller, validator) = _fieldOf(prev);

    _isValidating = true;
    final error = await validator(controller.text);
    _isValidating = false;

    if (!mounted) return;
    setState(() => _setError(prev, error));

    if (error != null) {
      // Fail → snap focus về field cũ
      tappedFocus.unfocus();
      prev.requestFocus();
    } else {
      _lastFocusedField = tappedFocus;
    }
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
    if (focusNode == _accountFocus) {
      _accountError = error;
    } else if (focusNode == _stockFocus) {
      _stockError = error;
    } else if (focusNode == _volumeFocus) {
      _volumeError = error;
    } else if (focusNode == _priceFocus) {
      _priceError = error;
    }
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
      _lastFocusedField = targetFocus;
      targetFocus.requestFocus();
    } else {
      _lastFocusedField = currentFocus;
      currentFocus.requestFocus();
    }
  }

  // ==========================================================================
  // Validators — mỗi field: (1) check local, (2) dispatch cubit, (3) await state
  // ==========================================================================

  // Dispatch cubit.validate(), await tới khi ra Success<T> hoặc Failure.
  // - Success → gọi onSuccess(data), trả về null (pass).
  // - Failure → trả về message (fail, hiển thị dưới field).
  Future<String?> _runCubitValidation<T, C extends FieldValidationCubit<T>>(
    String value, {
    required void Function(T data) onSuccess,
  }) async {
    final cubit = context.read<C>();
    cubit.validate(value);

    final state = await cubit.stream
        .firstWhere(
          (s) =>
              s is FieldValidationSuccess<T> || s is FieldValidationFailure<T>,
        )
        .timeout(
          const Duration(seconds: 5),
          onTimeout: () => FieldValidationFailure<T>('Timeout'),
        );

    switch (state) {
      case FieldValidationSuccess<T>(data: final data):
        onSuccess(data);
        return null;
      case FieldValidationFailure<T>(message: final msg):
        return msg;
      default:
        return null;
    }
  }

  Future<String?> _validateAccount(String value) async {
    if (value.isEmpty) return 'Account không được để trống';

    final selectCubit = context.read<SelectAccountCubit>();

    // Bắn vào SelectAccountCubit (share + trigger AccountCubit.requestAPI)
    selectCubit.select(value);

    // Lắng nghe response từ SelectAccountCubit (nó forward từ AccountCubit)
    final state = await selectCubit.stream
        .firstWhere(
          (s) => s is SelectAccountReceived || s is SelectAccountError,
        )
        .timeout(
          const Duration(seconds: 5),
          onTimeout: () => const SelectAccountError('Timeout'),
        );

    switch (state) {
      case SelectAccountReceived(model: final m):
        _accountModel = m;
        debugPrint('✓ Account pass → $_accountModel');
        return null;
      case SelectAccountError(message: final msg):
        return msg;
      default:
        return null;
    }
  }

  Future<String?> _validateStock(String value) async {
    if (value.isEmpty) return 'Stock không được để trống';
    return _runCubitValidation<StockModel, StockCubit>(
      value,
      onSuccess: (m) {
        _stockModel = m;
        debugPrint('✓ Stock pass → $_stockModel');
      },
    );
  }

  Future<String?> _validateVolume(String value) async {
    if (value.isEmpty) return 'Volume không được để trống';
    if (int.tryParse(value) == null) return 'Volume phải là số';
    return _runCubitValidation<VolumeModel, VolumeCubit>(
      value,
      onSuccess: (m) {
        _volumeModel = m;
        debugPrint('✓ Volume pass → $_volumeModel');
      },
    );
  }

  Future<String?> _validatePrice(String value) async {
    if (value.isEmpty) return 'Price không được để trống';
    if (double.tryParse(value) == null) return 'Price phải là số';
    return _runCubitValidation<PriceModel, PriceCubit>(
      value,
      onSuccess: (m) {
        _priceModel = m;
        debugPrint('✓ Price pass → $_priceModel');
      },
    );
  }

  // ==========================================================================
  // SILENT VALIDATE — chạy validator + show error, KHÔNG đụng focus.
  // Dùng khi fill giá trị bằng code (Sửa / Hủy).
  // ==========================================================================
  Future<void> _silentValidate(FocusNode focus) async {
    final (controller, validator) = _fieldOf(focus);
    final error = await validator(controller.text);
    if (!mounted) return;
    setState(() => _setError(focus, error));
  }

  // Mock data fill khi click Sửa / Hủy. Đổi tuỳ ý để test pass/fail.
  static const _mockAccount = 'ACC001';
  static const _mockStock = 'AAPL';
  static const _mockVolume = '100';
  static const _mockPrice = '50.5';

  void _onNewPressed() {
    if (_isValidating) return;
    setState(() {
      _mode = FormMode.normal;
      _accountController.clear();
      _stockController.clear();
      _volumeController.clear();
      _priceController.clear();
      _accountError = null;
      _stockError = null;
      _volumeError = null;
      _priceError = null;
      _accountModel = null;
      _stockModel = null;
      _volumeModel = null;
      _priceModel = null;
    });
    _lastFocusedField = _accountFocus;
    _accountFocus.requestFocus();
  }

  Future<void> _onEditPressed() async {
    if (_isValidating) return;
    _isValidating = true;

    setState(() {
      _mode = FormMode.edit;
      _accountController.text = _mockAccount;
      _stockController.text = _mockStock;
      _accountError = null;
      _stockError = null;
      _volumeError = null;
      _priceError = null;
    });

    // Validate 2 ô vừa fill, không snap focus
    await _silentValidate(_accountFocus);
    await _silentValidate(_stockFocus);

    _isValidating = false;
    if (!mounted) return;
    // Focus vào volume cho user nhập
    _lastFocusedField = _volumeFocus;
    _volumeFocus.requestFocus();
  }

  Future<void> _onCancelPressed() async {
    if (_isValidating) return;
    _isValidating = true;

    setState(() {
      _mode = FormMode.cancel;
      _accountController.text = _mockAccount;
      _stockController.text = _mockStock;
      _volumeController.text = _mockVolume;
      _priceController.text = _mockPrice;
      _accountError = null;
      _stockError = null;
      _volumeError = null;
      _priceError = null;
    });

    // Validate 4 ô lần lượt, không snap focus
    await _silentValidate(_accountFocus);
    await _silentValidate(_stockFocus);
    await _silentValidate(_volumeFocus);
    await _silentValidate(_priceFocus);

    _isValidating = false;
    if (!mounted) return;
    // Cancel mode: tất cả readOnly, bỏ focus
    FocusManager.instance.primaryFocus?.unfocus();
    _lastFocusedField = null;
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
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isValidating ? null : _onNewPressed,
                      icon: const Icon(Icons.note_add),
                      label: const Text('New'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isValidating ? null : _onEditPressed,
                      icon: const Icon(Icons.edit),
                      label: const Text('Sửa'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isValidating ? null : _onCancelPressed,
                      icon: const Icon(Icons.cancel),
                      label: const Text('Hủy'),
                    ),
                  ),
                ],
              ),
            ),
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
    final readOnly = _isReadOnly(focusNode);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Focus(
          onKeyEvent: (node, event) {
            // Trong cancel mode (full readOnly) bỏ qua keyboard nav,
            // tránh chạy validate vô nghĩa.
            if (readOnly && _mode == FormMode.cancel) {
              return KeyEventResult.ignored;
            }
            return _handleKeyEvent(
              focusNode,
              controller,
              validator,
              prevFocus,
              nextFocus,
              event,
            );
          },
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            readOnly: readOnly,
            onTap: () => _onPointerFocusChange(focusNode),
            decoration: InputDecoration(
              labelText: label,
              filled: readOnly,
              fillColor: readOnly ? Colors.white12 : null,
            ),
          ),
        ),
        if (error != null)
          Text(error, style: const TextStyle(color: Colors.red, fontSize: 12)),
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
