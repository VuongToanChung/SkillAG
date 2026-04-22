class AccountModel {
  final String id;
  final String displayName;
  const AccountModel({required this.id, required this.displayName});

  @override
  String toString() => 'AccountModel(id: $id, displayName: $displayName)';
}

class StockModel {
  final String symbol;
  final String name;
  const StockModel({required this.symbol, required this.name});

  @override
  String toString() => 'StockModel(symbol: $symbol, name: $name)';
}

class VolumeModel {
  final int value;
  const VolumeModel({required this.value});

  @override
  String toString() => 'VolumeModel(value: $value)';
}

class PriceModel {
  final double value;
  const PriceModel({required this.value});

  @override
  String toString() => 'PriceModel(value: $value)';
}
