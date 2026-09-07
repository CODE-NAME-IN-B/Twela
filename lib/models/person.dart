import 'package:uuid/uuid.dart';

enum DebtType { gave, received }

class Person {
  final String id;
  final String name;
  final String? phone;
  final DateTime createdAt;

  const Person({
    required this.id,
    required this.name,
    this.phone,
    required this.createdAt,
  });

  factory Person.create({required String name, String? phone}) {
    return Person(
      id: const Uuid().v4(),
      name: name,
      phone: phone,
      createdAt: DateTime.now(),
    );
  }

  Person copyWith({String? name, String? phone}) {
    return Person(
      id: id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Person.fromJson(Map<String, dynamic> json) {
    return Person(
      id: json['id'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
