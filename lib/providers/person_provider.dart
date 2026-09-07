import 'package:flutter/material.dart';
import '../models/person.dart';
import '../services/storage_service.dart';

class PersonProvider extends ChangeNotifier {
  final StorageService _storage;

  List<Person> _persons = [];

  PersonProvider(this._storage) {
    _persons = _storage.getPersons();
  }

  List<Person> get persons => _persons;

  Person? getPersonById(String id) {
    try {
      return _persons.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  Person? getPersonByName(String name) {
    try {
      return _persons.firstWhere((p) => p.name == name);
    } catch (_) {
      return null;
    }
  }

  Future<void> addPerson(Person person) async {
    _persons.insert(0, person);
    await _storage.savePersons(_persons);
    notifyListeners();
  }

  Future<void> updatePerson(Person person) async {
    final index = _persons.indexWhere((p) => p.id == person.id);
    if (index != -1) {
      _persons[index] = person;
      await _storage.savePersons(_persons);
      notifyListeners();
    }
  }

  Future<void> removePerson(String id) async {
    _persons.removeWhere((p) => p.id == id);
    await _storage.savePersons(_persons);
    notifyListeners();
  }
}
