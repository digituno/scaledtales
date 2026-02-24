import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// AsyncValue 상태(loading/error/data)를 일관된 UI로 처리하는 공통 위젯.
///
/// 사용 예시:
/// ```dart
/// AsyncValueWidget<List<Animal>>(
///   value: animalsAsync,
///   onRetry: () => ref.read(animalListProvider.notifier).refresh(),
///   data: (animals) => ListView.builder(...),
/// )
/// ```
class AsyncValueWidget<T> extends StatelessWidget {
  final AsyncValue<T> value;
  final Widget Function(T data) data;
  final VoidCallback? onRetry;

  const AsyncValueWidget({
    super.key,
    required this.value,
    required this.data,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return value.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(l10n.errorMessage),
            if (onRetry != null) ...[
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: onRetry,
                child: Text(l10n.retry),
              ),
            ],
          ],
        ),
      ),
      data: data,
    );
  }
}
