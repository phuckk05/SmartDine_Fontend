import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

@immutable
class User {
  final String name;
  final int age;

  const User(this.name, this.age);

  User copyWith({String? name, int? age}) {
    return User(name ?? this.name, age ?? this.age);
  }

  Map<String, dynamic> toMap() {
    return {'name': name, 'age': age};
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(map['name'] ?? '', map['age']?.toInt() ?? 0);
  }

  String toJson() => json.encode(toMap());

  factory User.fromJson(String source) => User.fromMap(json.decode(source));

  @override
  String toString() => 'User(name: $name, age: $age)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is User && other.name == name && other.age == age;
  }

  @override
  int get hashCode => name.hashCode ^ age.hashCode;
}

class UserNotifier extends StateNotifier<User> {
  UserNotifier() : super(const User('', 0));

  void updateName(String n) {
    state = state.copyWith(name: n);
  }

  void updateAge(String age) {
    state = state.copyWith(age: int.tryParse(age));
  }
}

//StateNotifierProvider
final userProvider = StateNotifierProvider<UserNotifier, User>(
  (ref) => UserNotifier(),
);

//FutureProvider
final ftechUserprovider = FutureProvider((ref) {
  const url = 'https://jsonplaceholder.typicode.com/users/1';
  return http.get(Uri.parse(url)).then((value) => User.fromJson(value.body));
},);