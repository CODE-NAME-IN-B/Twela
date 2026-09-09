class Debt {
  final String id;
  final String personName;
  final String itemDescription;
  final double totalAmount;
  final double paidAmount;
  final DateTime date;
  final bool isGiven;
  final String walletType;

  const Debt({
    required this.id,
    required this.personName,
    required this.itemDescription,
    required this.totalAmount,
    this.paidAmount = 0,
    required this.date,
    this.isGiven = true,
    this.walletType = 'cash',
  });

  double get remaining => totalAmount - paidAmount;
  bool get isPaidOff => remaining <= 0;

  Debt copyWith({
    String? id,
    String? personName,
    String? itemDescription,
    double? totalAmount,
    double? paidAmount,
    DateTime? date,
    bool? isGiven,
    String? walletType,
  }) {
    return Debt(
      id: id ?? this.id,
      personName: personName ?? this.personName,
      itemDescription: itemDescription ?? this.itemDescription,
      totalAmount: totalAmount ?? this.totalAmount,
      paidAmount: paidAmount ?? this.paidAmount,
      date: date ?? this.date,
      isGiven: isGiven ?? this.isGiven,
      walletType: walletType ?? this.walletType,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'personName': personName,
      'itemDescription': itemDescription,
      'totalAmount': totalAmount,
      'paidAmount': paidAmount,
      'date': date.toIso8601String(),
      'isGiven': isGiven,
      'walletType': walletType,
    };
  }

  factory Debt.fromJson(Map<String, dynamic> json) {
    return Debt(
      id: json['id'] as String,
      personName: json['personName'] as String,
      itemDescription: json['itemDescription'] as String,
      totalAmount: (json['totalAmount'] as num).toDouble(),
      paidAmount: (json['paidAmount'] as num?)?.toDouble() ?? 0,
      date: DateTime.parse(json['date'] as String),
      isGiven: json['isGiven'] as bool? ?? true,
      walletType: json['walletType'] as String? ?? 'cash',
    );
  }
}
