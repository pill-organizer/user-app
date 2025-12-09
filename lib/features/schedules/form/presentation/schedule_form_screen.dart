import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/config/theme.dart';
import '../../common/model/schedule.dart';
import '../../common/repository/schedule_repository.dart';
import '../../common/bloc/schedule_form_bloc.dart';
import 'schedule_form_notifier.dart';

class ScheduleFormScreen extends StatefulWidget {
  final String? scheduleId;

  const ScheduleFormScreen({super.key, this.scheduleId});

  @override
  State<ScheduleFormScreen> createState() => _ScheduleFormScreenState();
}

class _ScheduleFormScreenState extends State<ScheduleFormScreen> {
  late final ScheduleFormNotifier _notifier;

  @override
  void initState() {
    super.initState();
    _notifier = ScheduleFormNotifier(scheduleId: widget.scheduleId);
  }

  @override
  void dispose() {
    _notifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final bloc = ScheduleFormBloc(repository: context.read<ScheduleRepository>());
        if (widget.scheduleId != null) {
          bloc.add(ScheduleFormLoadRequested(widget.scheduleId!));
        }
        return bloc;
      },
      child: ScheduleFormProvider(notifier: _notifier, child: const _ScheduleFormContent()),
    );
  }
}

class _ScheduleFormContent extends StatefulWidget {
  const _ScheduleFormContent();

  @override
  State<_ScheduleFormContent> createState() => _ScheduleFormContentState();
}

class _ScheduleFormContentState extends State<_ScheduleFormContent> {
  final _formKey = GlobalKey<FormState>();

  void _populateForm(Schedule schedule) {
    final notifier = ScheduleFormProvider.of(context);
    notifier.loadSchedule(schedule);
  }

  Future<void> _selectTime() async {
    final notifier = ScheduleFormProvider.of(context);
    final picked = await showTimePicker(context: context, initialTime: notifier.time);
    if (picked != null) {
      notifier.setTime(picked);
    }
  }

  void _saveSchedule() {
    final notifier = ScheduleFormProvider.of(context);

    if (_formKey.currentState!.validate()) {
      if (notifier.days.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select at least one day'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
        return;
      }

      if (notifier.isEditing) {
        context.read<ScheduleFormBloc>().add(ScheduleFormUpdateRequested(notifier.schedule));
      } else {
        context.read<ScheduleFormBloc>().add(ScheduleFormCreateRequested(notifier.schedule));
      }
    }
  }

  void _confirmDelete() {
    final notifier = ScheduleFormProvider.of(context);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Schedule'),
        content: const Text(
          'Are you sure you want to delete this schedule? This action cannot be undone.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<ScheduleFormBloc>().add(ScheduleFormDeleteRequested(notifier.id!));
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorColor),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ScheduleFormProvider.of(context);

    return BlocConsumer<ScheduleFormBloc, ScheduleFormState>(
      listener: (context, state) {
        if (state is ScheduleFormLoaded) {
          _populateForm(state.schedule);
        } else if (state is ScheduleFormSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: AppTheme.successColor),
          );
          Navigator.pop(context);
        } else if (state is ScheduleFormError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: AppTheme.errorColor),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is ScheduleFormLoading;

        return Scaffold(
          appBar: AppBar(
            title: Text(notifier.isEditing ? 'Edit Schedule' : 'New Schedule'),
            actions: [
              if (notifier.isEditing)
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  color: AppTheme.errorColor,
                  onPressed: isLoading ? null : _confirmDelete,
                ),
            ],
          ),
          body: isLoading
              ? const Center(child: CircularProgressIndicator())
              : Form(
                  key: _formKey,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _PillNameCard(
                        initialPillName: state is ScheduleFormLoaded ? state.schedule.pillName : '',
                      ),
                      const SizedBox(height: 16),
                      _TimeCard(onTap: _selectTime),
                      const SizedBox(height: 16),
                      const _DaysCard(),
                      const SizedBox(height: 16),
                      const _EnabledCard(),
                      const SizedBox(height: 32),
                      ElevatedButton(
                        onPressed: _saveSchedule,
                        child: Text(notifier.isEditing ? 'Update Schedule' : 'Create Schedule'),
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }
}

class _PillNameCard extends StatelessWidget {
  const _PillNameCard({required this.initialPillName});

  final String initialPillName;

  @override
  Widget build(BuildContext context) {
    final notifier = ScheduleFormProvider.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          spacing: 16,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Pill Information', style: Theme.of(context).textTheme.titleMedium),
            TextFormField(
              key: ValueKey(initialPillName),
              onChanged: (value) => notifier.setPillName(value),
              initialValue: initialPillName,
              decoration: const InputDecoration(
                labelText: 'Pill Name',
                hintText: 'Enter pill name',
                prefixIcon: Icon(Icons.medication_outlined),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter pill name';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _TimeCard extends StatelessWidget {
  const _TimeCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final notifier = ScheduleFormProvider.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Time', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.access_time, color: AppTheme.primaryColor, size: 32),
                    const SizedBox(width: 16),
                    Text(
                      notifier.time.format(context),
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DaysCard extends StatelessWidget {
  const _DaysCard();

  @override
  Widget build(BuildContext context) {
    final notifier = ScheduleFormProvider.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Days', style: Theme.of(context).textTheme.titleMedium),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (value) {
                    switch (value) {
                      case 'all':
                        notifier.selectAllDays();
                        break;
                      case 'weekdays':
                        notifier.selectWeekdays();
                        break;
                      case 'weekends':
                        notifier.selectWeekends();
                        break;
                    }
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(value: 'all', child: Text('Every day')),
                    PopupMenuItem(value: 'weekdays', child: Text('Weekdays')),
                    PopupMenuItem(value: 'weekends', child: Text('Weekends')),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(7, (index) {
                final day = WeekDay.fromInt(index + 1);
                final isSelected = notifier.days.contains(day);
                return GestureDetector(
                  onTap: () => notifier.toggleDay(day),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.primaryColor : Colors.transparent,
                      borderRadius: BorderRadius.circular(21),
                      border: Border.all(
                        color: isSelected ? AppTheme.primaryColor : AppTheme.dividerColor,
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        day.shortName,
                        style: TextStyle(
                          color: isSelected ? Colors.white : AppTheme.textSecondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                WeekDay.getReadableDays(notifier.days),
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EnabledCard extends StatelessWidget {
  const _EnabledCard();

  @override
  Widget build(BuildContext context) {
    final notifier = ScheduleFormProvider.of(context);

    return Card(
      child: SwitchListTile(
        title: const Text('Enabled'),
        subtitle: Text(notifier.enabled ? 'Schedule is active' : 'Schedule is paused'),
        value: notifier.enabled,
        onChanged: notifier.setEnabled,
      ),
    );
  }
}
