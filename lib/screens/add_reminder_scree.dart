import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../cubit/reminder_cubit.dart';
import '../models/reminder_model.dart';

class AddReminderScreen extends StatefulWidget {
  final ReminderModel? reminder;

  const AddReminderScreen({super.key, this.reminder});

  @override
  State<AddReminderScreen> createState() => _AddReminderScreenState();
}

class _AddReminderScreenState extends State<AddReminderScreen> {
  final _titleController = TextEditingController();
  final _noteController = TextEditingController();
  DateTime _selectedDate = DateTime.now().add(const Duration(hours: 1));

  int _selectedTextColor = 0xFF1A1A1A;
  int _selectedBgColor = 0xFFFFE082;
  String _selectedSticker = '⭐';

  final List<int> _textColors = [
    0xFF1A1A1A,
    0xFFFFFFFF,
    0xFFE91E63,
    0xFF9C27B0,
    0xFF3F51B5,
    0xFF2196F3,
    0xFF00BCD4,
    0xFF4CAF50,
    0xFFFFEB3B,
    0xFFFF9800,
    0xFFFF5722,
    0xFF795548,
  ];

  final List<int> _bgColors = [
    0xFFFFE082,
    0xFFFFCDD2,
    0xFFF8BBD0,
    0xFFE1BEE7,
    0xFFD1C4E9,
    0xFFC5CAE9,
    0xFFBBDEFB,
    0xFFB3E5FC,
    0xFFB2DFDB,
    0xFFC8E6C9,
    0xFFF0F4C3,
    0xFFFFE0B2,
    0xFFFFCCBC,
    0xFFD7CCC8,
    0xFFCFD8DC,
    0xFFFFF9C4,
  ];

  final List<String> _stickers = [
    '⭐',
    '🎯',
    '💡',
    '🔥',
    '💪',
    '🎉',
    '🎨',
    '📚',
    '💼',
    '🏃',
    '🎵',
    '☕',
    '🍕',
    '✈️',
    '🏠',
    '❤️',
    '🌟',
    '🎁',
    '🌈',
    '🦋',
    '🌸',
    '🎭',
    '🎮',
    '📱',
  ];

  bool _isSticker = false;

  @override
  void initState() {
    super.initState();
    if (widget.reminder != null) {
      _titleController.text = widget.reminder!.title;
      _noteController.text = widget.reminder!.note;
      _selectedDate = widget.reminder!.dateTime;
      _selectedTextColor = widget.reminder!.textColor;
      _selectedBgColor = widget.reminder!.backgroundColor;
      _selectedSticker = widget.reminder!.sticker;
      _isSticker = widget.reminder!.isPinnedToWidget;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.purple.shade50,
              Colors.blue.shade50,
              Colors.pink.shade50,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(context),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildPreviewCard(),
                      const SizedBox(height: 24),
                      _buildStickerSelector(),
                      const SizedBox(height: 24),
                      _buildTextField(
                        controller: _titleController,
                        label: 'Title',
                        hint: 'Enter reminder title',
                        icon: Icons.title,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _noteController,
                        label: 'Note',
                        hint: 'Enter detailed note...',
                        icon: Icons.note,
                        maxLines: 5,
                      ),
                      const SizedBox(height: 24),
                      _buildDateTimePicker(),
                      const SizedBox(height: 24),
                      _buildColorPicker(
                        'Text Color',
                        _textColors,
                        _selectedTextColor,
                        (color) {
                          setState(() => _selectedTextColor = color);
                        },
                      ),
                      const SizedBox(height: 24),
                      _buildColorPicker(
                        'Background Color',
                        _bgColors,
                        _selectedBgColor,
                        (color) {
                          setState(() => _selectedBgColor = color);
                        },
                      ),
                      const SizedBox(height: 24),
                      _buildWallpaperCheckbox(),
                      const SizedBox(height: 32),
                      _buildSaveButton(context),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          Text(
            widget.reminder == null ? 'New Reminder' : 'Edit Reminder',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Color(_selectedBgColor),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Color(_selectedBgColor).withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(_selectedSticker, style: const TextStyle(fontSize: 32)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _titleController.text.isEmpty
                      ? 'Preview Title'
                      : _titleController.text,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(_selectedTextColor),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _noteController.text.isEmpty
                ? 'Your note will appear here...'
                : _noteController.text,
            style: TextStyle(
              fontSize: 16,
              color: Color(_selectedTextColor).withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStickerSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Choose Sticker',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Container(
          height: 60,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            itemCount: _stickers.length,
            itemBuilder: (context, index) {
              final sticker = _stickers[index];
              final isSelected = sticker == _selectedSticker;
              return GestureDetector(
                onTap: () => setState(() => _selectedSticker = sticker),
                child: Container(
                  width: 50,
                  margin: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.purple.shade100
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? Colors.purple : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(sticker, style: const TextStyle(fontSize: 28)),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
          ),
          onChanged: (_) => setState(() {}),
        ),
      ],
    );
  }

  Widget _buildDateTimePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Date & Time',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _pickDateTime,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, color: Colors.purple),
                const SizedBox(width: 12),
                Text(
                  '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year} at ${_selectedDate.hour}:${_selectedDate.minute.toString().padLeft(2, '0')}',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDate),
      );

      if (time != null) {
        setState(() {
          _selectedDate = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  Widget _buildColorPicker(
    String label,
    List<int> colors,
    int selected,
    Function(int) onSelect,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Container(
          height: 60,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            itemCount: colors.length,
            itemBuilder: (context, index) {
              final color = colors[index];
              final isSelected = color == selected;
              return GestureDetector(
                onTap: () => onSelect(color),
                child: Container(
                  width: 50,
                  height: 50,
                  margin: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Color(color),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? Colors.black : Colors.grey.shade300,
                      width: isSelected ? 3 : 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: Color(color).withOpacity(0.4),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, color: Colors.white)
                      : null,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildWallpaperCheckbox() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.purple.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.wallpaper,
              color: Colors.purple.shade700,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Add Sticker to Wallpaper',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'Show this reminder as a widget on home screen',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          Transform.scale(
            scale: 1.2,
            child: Checkbox(
              value: _isSticker,
              onChanged: (value) {
                setState(() => _isSticker = value ?? false);
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
              activeColor: Colors.deepPurple,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _saveReminder,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.save),
            const SizedBox(width: 8),
            Text(
              widget.reminder == null ? 'Create Reminder' : 'Update Reminder',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  void _saveReminder() {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter a title')));
      return;
    }

    final reminder = ReminderModel(
      id: widget.reminder?.id ?? const Uuid().v4(),
      title: _titleController.text,
      note: _noteController.text,
      dateTime: _selectedDate,
      textColor: _selectedTextColor,
      backgroundColor: _selectedBgColor,
      sticker: _selectedSticker,
      isCompleted: widget.reminder?.isCompleted ?? false,
      isPinnedToWidget: _isSticker,
    );

    if (widget.reminder == null) {
      context.read<ReminderCubit>().addReminder(reminder);
    } else {
      context.read<ReminderCubit>().updateReminder(reminder);
    }

    Navigator.pop(context);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _noteController.dispose();
    super.dispose();
  }
}
