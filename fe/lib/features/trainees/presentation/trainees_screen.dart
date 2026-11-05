import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/trainee_status.dart';
import '../../../core/router/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/phone_format.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/async_value_view.dart';
import '../../../core/widgets/choice_row.dart';
import '../../../core/widgets/link_button.dart';
import '../../../core/widgets/list_row.dart';
import '../../../core/widgets/state_views.dart';
import '../domain/trainee.dart';
import 'trainee_avatar.dart';
import 'trainee_providers.dart';

// Inactive trainees stay readable but recede behind the active roster.
const _inactiveOpacity = 0.6;

const _statusOptions = [
  ChoiceOption(value: TraineeStatus.active, label: 'Active'),
  ChoiceOption(value: TraineeStatus.inactive, label: 'Inactive'),
];

/// The roster: search by name or phone, active or inactive, tap for the detail.
class TraineesScreen extends ConsumerStatefulWidget {
  const TraineesScreen({super.key});

  @override
  ConsumerState<TraineesScreen> createState() => _TraineesScreenState();
}

class _TraineesScreenState extends ConsumerState<TraineesScreen> {
  final search = TextEditingController();
  var query = '';
  var status = TraineeStatus.active;

  @override
  void initState() {
    super.initState();
    search.addListener(onSearchChanged);
  }

  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }

  // The listener also fires on cursor moves; only a text change rebuilds.
  void onSearchChanged() {
    if (search.text != query) setState(() => query = search.text);
  }

  void selectStatus(TraineeStatus next) => setState(() => status = next);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Students'),
        actions: [
          LinkButton(
            label: 'Add',
            onPressed: () => context.push(Routes.traineeNew),
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.gutter,
              AppSpacing.sm,
              AppSpacing.gutter,
              AppSpacing.md,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppTextField(
                  controller: search,
                  label: 'Search',
                  hint: 'Name or phone',
                  textInputAction: TextInputAction.search,
                ),
                const SizedBox(height: AppSpacing.md),
                ChoiceRow<TraineeStatus>(
                  options: _statusOptions,
                  selected: status,
                  onSelected: selectStatus,
                ),
              ],
            ),
          ),
          Expanded(
            child: AsyncValueView<List<Trainee>>(
              value: ref.watch(traineeListProvider(status)),
              onRetry: () => ref.invalidate(traineeListProvider(status)),
              isEmpty: (trainees) => trainees.isEmpty,
              empty: status == TraineeStatus.inactive
                  ? EmptyView(
                      title: 'No inactive students',
                      message: 'Students you set inactive are listed here.',
                      actionLabel: 'Show active',
                      onAction: () => selectStatus(TraineeStatus.active),
                    )
                  : EmptyView(
                      title: 'No students yet',
                      message:
                          'Add the first student to start marking attendance.',
                      actionLabel: 'Add student',
                      onAction: () => context.push(Routes.traineeNew),
                    ),
              data: (trainees) => _TraineeList(
                trainees: filterTrainees(trainees, query),
                onClearSearch: search.clear,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TraineeList extends StatelessWidget {
  const _TraineeList({required this.trainees, required this.onClearSearch});

  final List<Trainee> trainees;
  final VoidCallback onClearSearch;

  @override
  Widget build(BuildContext context) {
    if (trainees.isEmpty) {
      return EmptyView(
        title: 'No one matches',
        message: 'Try another name or phone number.',
        actionLabel: 'Clear search',
        onAction: onClearSearch,
      );
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.gutter,
        0,
        AppSpacing.gutter,
        AppSpacing.lg,
      ),
      children: [
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: ListRow.divide([
              for (final trainee in trainees)
                _TraineeRow(key: ValueKey(trainee.id), trainee: trainee),
            ]),
          ),
        ),
      ],
    );
  }
}

class _TraineeRow extends StatelessWidget {
  const _TraineeRow({super.key, required this.trainee});

  final Trainee trainee;

  @override
  Widget build(BuildContext context) {
    final phone = trainee.phone;
    final row = ListRow(
      leading: TraineeAvatar(trainee: trainee),
      title: trainee.fullName,
      subtitle: phone == null ? 'No phone' : formatPhone(phone),
      trailing: const Icon(Icons.chevron_right, color: AppColors.muted),
      onTap: () => context.push(Routes.traineeDetailOf(trainee.id)),
    );
    return trainee.isActive
        ? row
        : Opacity(opacity: _inactiveOpacity, child: row);
  }
}
