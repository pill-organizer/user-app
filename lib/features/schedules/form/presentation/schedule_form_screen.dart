import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/config/theme.dart';
import '../../common/model/schedule.dart';
import '../../common/repository/schedule_repository.dart';
import '../../common/bloc/schedule_form_bloc.dart';

class ScheduleFormScreen extends StatelessWidget {
  final String? scheduleId;

  const ScheduleFormScreen({super.key, this.scheduleId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final bloc = ScheduleFormBloc(repository: context.read<ScheduleRepository>());
        if (scheduleId != null) {
          bloc.add(ScheduleFormLoadRequested(scheduleId!));
        }
        return bloc;
      },
      child: _ScheduleFormContent(scheduleId: scheduleId),
    );
  }
}

class _ScheduleFormContent extends StatefulWidget {
  final String? scheduleId;

  const _ScheduleFormContent({this.scheduleId});

  @override
  State<_ScheduleFormContent> createState() => _ScheduleFormContentState();
}

class _ScheduleFormContentState extends State<_ScheduleFormContent> {
  final _formKey = GlobalKey<FormState>();
  final _pillNameController = TextEditingController();
  TimeOfDay _selectedTime = TimeOfDay.now();

  final Set<WeekDay> _selectedDays = WeekDay.values.toSet(); // All days selected

  bool _isEnabled = true;
  bool _hasLoadedData = false;
  bool get _isEditing => widget.scheduleId != null;

  @override
  void dispose() {
    _pillNameController.dispose();
    super.dispose();
  }

  void _populateForm(Schedule schedule) {
    if (_hasLoadedData) return;
    _hasLoadedData = true;
    _pillNameController.text = schedule.pillName;
    _selectedTime = schedule.time;
    _selectedDays.clear();
    _selectedDays.addAll(schedule.days);
    _isEnabled = schedule.enabled;
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(context: context, initialTime: _selectedTime);
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _toggleDay(WeekDay day) {
    setState(() {
      if (_selectedDays.contains(day)) {
        if (_selectedDays.length > 1) {
          _selectedDays.remove(day);
        }
      } else {
        _selectedDays.add(day);
      }
    });
  }

  void _selectAllDays() {
    setState(() {
      _selectedDays.addAll([
        WeekDay.mon,
        WeekDay.tue,
        WeekDay.wed,
        WeekDay.thu,
        WeekDay.fri,
        WeekDay.sat,
        WeekDay.sun,
      ]);
    });
  }

  void _selectWeekdays() {
    setState(() {
      _selectedDays.clear();
      _selectedDays.addAll([WeekDay.mon, WeekDay.tue, WeekDay.wed, WeekDay.thu, WeekDay.fri]);
    });
  }

  void _selectWeekends() {
    setState(() {
      _selectedDays.clear();
      _selectedDays.addAll([WeekDay.sat, WeekDay.sun]);
    });
  }

  void _saveSchedule() {
    if (_formKey.currentState!.validate()) {
      if (_selectedDays.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select at least one day'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
        return;
      }

      final schedule = Schedule(
        id: widget.scheduleId,
        pillName: _pillNameController.text.trim(),
        time: _selectedTime,
        days: _selectedDays,
        enabled: _isEnabled,
      );

      if (_isEditing) {
        context.read<ScheduleFormBloc>().add(ScheduleFormUpdateRequested(schedule));
      } else {
        context.read<ScheduleFormBloc>().add(ScheduleFormCreateRequested(schedule));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ScheduleFormBloc, ScheduleFormState>(
      listener: (context, state) {
        if (state is ScheduleFormLoaded) {
          _populateForm(state.schedule);

          setState(() {});
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
            title: Text(_isEditing ? 'Edit Schedule' : 'New Schedule'),
            actions: [
              if (_isEditing)
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
                    shrinkWrap: true,
                    children: [
                      // Pill Name
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Pill Information',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _pillNameController,
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
                      ),
                      const SizedBox(height: 16),

                      // Time Selection
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Time', style: Theme.of(context).textTheme.titleMedium),
                              const SizedBox(height: 16),
                              InkWell(
                                onTap: _selectTime,
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
                                      const Icon(
                                        Icons.access_time,
                                        color: AppTheme.primaryColor,
                                        size: 32,
                                      ),
                                      const SizedBox(width: 16),
                                      Text(
                                        _selectedTime.format(context),
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
                      ),
                      const SizedBox(height: 16),

                      // Days Selection
                      Card(
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
                                          _selectAllDays();
                                          break;
                                        case 'weekdays':
                                          _selectWeekdays();
                                          break;
                                        case 'weekends':
                                          _selectWeekends();
                                          break;
                                      }
                                    },
                                    itemBuilder: (context) => [
                                      const PopupMenuItem(value: 'all', child: Text('Every day')),
                                      const PopupMenuItem(
                                        value: 'weekdays',
                                        child: Text('Weekdays'),
                                      ),
                                      const PopupMenuItem(
                                        value: 'weekends',
                                        child: Text('Weekends'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: List.generate(7, (index) {
                                  final day = WeekDay.fromInt(index + 1);
                                  final isSelected = _selectedDays.contains(day);
                                  return GestureDetector(
                                    onTap: () => _toggleDay(day),
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      width: 42,
                                      height: 42,
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? AppTheme.primaryColor
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(21),
                                        border: Border.all(
                                          color: isSelected
                                              ? AppTheme.primaryColor
                                              : AppTheme.dividerColor,
                                          width: 2,
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          day.shortName,

                                          style: TextStyle(
                                            color: isSelected
                                                ? Colors.white
                                                : AppTheme.textSecondary,
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
                                  WeekDay.getReadableDays(_selectedDays),
                                  style: Theme.of(
                                    context,
                                  ).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Status
                      Card(
                        child: SwitchListTile(
                          title: const Text('Enabled'),
                          subtitle: Text(_isEnabled ? 'Schedule is active' : 'Schedule is paused'),
                          value: _isEnabled,
                          onChanged: (value) {
                            setState(() {
                              _isEnabled = value;
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Save Button
                      ElevatedButton(
                        onPressed: _saveSchedule,
                        child: Text(_isEditing ? 'Update Schedule' : 'Create Schedule'),
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }

  void _confirmDelete() => showDialog(
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
            context.read<ScheduleFormBloc>().add(ScheduleFormDeleteRequested(widget.scheduleId!));
          },
          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorColor),
          child: const Text('Delete'),
        ),
      ],
    ),
  );
}
