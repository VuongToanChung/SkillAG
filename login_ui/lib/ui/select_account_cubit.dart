import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'field_validation_cubit.dart';
import 'models.dart';

// State của SelectAccountCubit — share thông tin account đã chọn cho các
// component khác trong app (orchestrator giữa UI và AccountCubit).
sealed class SelectAccountState {
  const SelectAccountState();
}

class SelectAccountInitial extends SelectAccountState {
  const SelectAccountInitial();
}

// Vừa nhận selection từ UI, đang chờ AccountCubit trả response.
class SelectAccountSelected extends SelectAccountState {
  final String code;
  const SelectAccountSelected(this.code);
}

// Forward Success từ AccountCubit.
class SelectAccountReceived extends SelectAccountState {
  final AccountModel model;
  const SelectAccountReceived(this.model);
}

// Forward Failure từ AccountCubit.
class SelectAccountError extends SelectAccountState {
  final String message;
  const SelectAccountError(this.message);
}

class SelectAccountCubit extends Cubit<SelectAccountState> {
  final AccountCubit _accountCubit;
  StreamSubscription<FieldValidationState<AccountModel>>? _sub;

  SelectAccountCubit(this._accountCubit) : super(const SelectAccountInitial()) {
    // Lắng nghe AccountCubit, forward Success/Failure ra state của mình
    // → các component (gồm validator) chỉ cần listen SelectAccountCubit.
    _sub = _accountCubit.stream.listen(_onAccountStateChanged);
  }

  // Entry point từ UI: bắn selection vào, đồng thời trigger API.
  void select(String code) {
    emit(SelectAccountSelected(code));
    _accountCubit.requestAPI(code);
  }

  void _onAccountStateChanged(FieldValidationState<AccountModel> s) {
    switch (s) {
      case FieldValidationSuccess<AccountModel>(data: final m):
        emit(SelectAccountReceived(m));
      case FieldValidationFailure<AccountModel>(message: final msg):
        emit(SelectAccountError(msg));
      case FieldValidationLoading<AccountModel>():
      case FieldValidationInitial<AccountModel>():
        // ignore
        break;
    }
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
