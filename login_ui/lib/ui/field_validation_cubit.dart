import 'package:flutter_bloc/flutter_bloc.dart';

import 'models.dart';

sealed class FieldValidationState<T> {
  const FieldValidationState();
}

class FieldValidationInitial<T> extends FieldValidationState<T> {
  const FieldValidationInitial();
}

class FieldValidationLoading<T> extends FieldValidationState<T> {
  const FieldValidationLoading();
}

class FieldValidationSuccess<T> extends FieldValidationState<T> {
  final T data;
  const FieldValidationSuccess(this.data);
}

class FieldValidationFailure<T> extends FieldValidationState<T> {
  final String message;
  const FieldValidationFailure(this.message);
}

// Base cubit: mỗi sub-class override validate() để emit Success<T>(model)
// hoặc Failure(message).
abstract class FieldValidationCubit<T> extends Cubit<FieldValidationState<T>> {
  FieldValidationCubit() : super(FieldValidationInitial<T>());

  Future<void> validate(String value);
}

class AccountCubit extends FieldValidationCubit<AccountModel> {
  // Public API call. Được trigger bởi SelectAccountCubit, KHÔNG gọi trực
  // tiếp từ UI (validator) nữa.
  Future<void> requestAPI(String value) async {
    emit(const FieldValidationLoading());
    await Future<void>.delayed(const Duration(milliseconds: 300));
    // Mock: luôn thành công, trả về AccountModel
    emit(
      FieldValidationSuccess(
        AccountModel(id: value, displayName: 'Account: $value'),
      ),
    );
    // Để test fail, comment 4 dòng emit Success trên và uncomment:
    // emit(const FieldValidationFailure('Account không tồn tại'));
  }

  // Giữ override để base class không vỡ — delegate sang requestAPI.
  @override
  Future<void> validate(String value) => requestAPI(value);
}

class StockCubit extends FieldValidationCubit<StockModel> {
  @override
  Future<void> validate(String value) async {
    emit(const FieldValidationLoading());
    await Future<void>.delayed(const Duration(milliseconds: 300));
    emit(
      FieldValidationSuccess(
        StockModel(symbol: value.toUpperCase(), name: 'Stock $value'),
      ),
    );
  }
}

class VolumeCubit extends FieldValidationCubit<VolumeModel> {
  @override
  Future<void> validate(String value) async {
    emit(const FieldValidationLoading());
    await Future<void>.delayed(const Duration(milliseconds: 300));
    emit(FieldValidationSuccess(VolumeModel(value: int.parse(value))));
  }
}

class PriceCubit extends FieldValidationCubit<PriceModel> {
  @override
  Future<void> validate(String value) async {
    emit(const FieldValidationLoading());
    await Future<void>.delayed(const Duration(milliseconds: 300));
    emit(FieldValidationSuccess(PriceModel(value: double.parse(value))));
  }
}
