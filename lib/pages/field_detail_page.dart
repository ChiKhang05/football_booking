import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FieldDetailPage extends StatefulWidget {
  final Map field;
  const FieldDetailPage({super.key, required this.field});

  @override
  State<FieldDetailPage> createState() => _FieldDetailPageState();
}

class _FieldDetailPageState extends State<FieldDetailPage> {
  final _formKey = GlobalKey<FormState>();
  DateTime? selectedDate;
  TimeOfDay? startTime;
  TimeOfDay? endTime;
  bool isLoading = false;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context, bool isStart) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStart ? (startTime ?? TimeOfDay.now()) : (endTime ?? TimeOfDay.now()),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          startTime = picked;
        } else {
          endTime = picked;
        }
      });
    }
  }

  Future<void> bookField() async {
    if (!_formKey.currentState!.validate()) return;
    if (selectedDate == null || startTime == null || endTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng chọn đầy đủ ngày và giờ")),
      );
      return;
    }

    final startDateTime = DateTime(
      selectedDate!.year,
      selectedDate!.month,
      selectedDate!.day,
      startTime!.hour,
      startTime!.minute,
    );
    final endDateTime = DateTime(
      selectedDate!.year,
      selectedDate!.month,
      selectedDate!.day,
      endTime!.hour,
      endTime!.minute,
    );

    if (startDateTime.isAfter(endDateTime)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Thời gian bắt đầu phải trước thời gian kết thúc")),
      );
      return;
    }

    setState(() => isLoading = true);
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser!;

    try {
      await supabase.from('bookings').insert({
        'user_id': user.id,
        'field_id': widget.field['id'],
        'start_ts': startDateTime.toIso8601String(),
        'end_ts': endDateTime.toIso8601String(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Đặt sân thành công!")),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.field['name']),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Field Info Card
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.sports_soccer, color: Colors.green, size: 32),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              widget.field['name'],
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (widget.field['location'] != null)
                        Row(
                          children: [
                            const Icon(Icons.location_on, color: Colors.grey),
                            const SizedBox(width: 8),
                            Text(widget.field['location']),
                          ],
                        ),
                      const SizedBox(height: 8),
                      if (widget.field['description'] != null)
                        Text(
                          widget.field['description'],
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Booking Form
              const Text(
                "Đặt sân",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // Date Selection
              Card(
                elevation: 2,
                child: ListTile(
                  title: const Text("Chọn ngày"),
                  subtitle: Text(
                    selectedDate == null
                        ? "Chưa chọn ngày"
                        : "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () => _selectDate(context),
                ),
              ),
              const SizedBox(height: 12),

              // Start Time
              Card(
                elevation: 2,
                child: ListTile(
                  title: const Text("Giờ bắt đầu"),
                  subtitle: Text(
                    startTime == null
                        ? "Chưa chọn giờ"
                        : startTime!.format(context),
                  ),
                  trailing: const Icon(Icons.access_time),
                  onTap: () => _selectTime(context, true),
                ),
              ),
              const SizedBox(height: 12),

              // End Time
              Card(
                elevation: 2,
                child: ListTile(
                  title: const Text("Giờ kết thúc"),
                  subtitle: Text(
                    endTime == null
                        ? "Chưa chọn giờ"
                        : endTime!.format(context),
                  ),
                  trailing: const Icon(Icons.access_time),
                  onTap: () => _selectTime(context, false),
                ),
              ),
              const SizedBox(height: 24),

              // Book Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : bookField,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: Colors.green,
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator()
                      : const Text(
                          "Đặt sân",
                          style: TextStyle(fontSize: 18),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
