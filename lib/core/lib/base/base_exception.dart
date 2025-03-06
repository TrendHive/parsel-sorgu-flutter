import 'package:core/base/base_cause.dart';
import 'package:core/exception/code/exception_code.dart';
import 'package:flutter/material.dart';

@immutable
abstract class BaseException implements Exception {
  final String? message;
  final ExceptionCode? code;
  final BaseCause? cause;

  const BaseException({required this.message, this.code, this.cause});

  @override
  String toString() =>
      'BaseException(message: ${message.toString()}, code: ${code.toString()})';
}
