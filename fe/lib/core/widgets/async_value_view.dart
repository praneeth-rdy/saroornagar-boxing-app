import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';

import '../errors/app_exception.dart';
import 'state_views.dart';

/// Renders an [AsyncValue] through the shared loading, error, permission and empty views.
class AsyncValueView<T> extends StatelessWidget {
  const AsyncValueView({
    super.key,
    required this.value,
    required this.data,
    this.onRetry,
    this.isEmpty,
    this.empty,
  });

  final AsyncValue<T> value;
  final Widget Function(T value) data;
  final VoidCallback? onRetry;
  final bool Function(T value)? isEmpty;
  final Widget? empty;

  @override
  Widget build(BuildContext context) {
    return value.when(
      loading: () => const LoadingView(),
      error: (error, _) => _errorView(_unwrap(error)),
      data: (result) {
        final emptyView = empty;
        if (emptyView != null && isEmpty?.call(result) == true) {
          return emptyView;
        }
        return data(result);
      },
    );
  }

  Widget _errorView(Object error) {
    if (error is PermissionException) {
      return PermissionDeniedView(message: error.message);
    }
    final message = error is AppException
        ? error.message
        : UnknownException.defaultMessage;
    return ErrorView(message: message, onRetry: onRetry);
  }

  // A provider that reads a failed provider receives the failure wrapped.
  static Object _unwrap(Object error) {
    var current = error;
    while (current is ProviderException) {
      current = current.exception;
    }
    return current;
  }
}
