import 'package:flutter/material.dart';

Widget CustomTextFormField({
  required TextEditingController controller,
  required String label,
  required String hint,
  bool multiline = false,
  bool disabled = false,
  bool readOnly = false,
  TextInputType keyboardType = TextInputType.text,
}) {
  return TextFormField(
    readOnly: readOnly,
    controller: controller,
    keyboardType: keyboardType,
    enabled: !disabled,
    maxLines: multiline ? null : 1,
    decoration: InputDecoration(
      enabled: !disabled,
      label: Text(label),
      labelStyle: const TextStyle(
        overflow: TextOverflow.ellipsis,
      ),
      hintText: hint,
      border: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.black12),
        borderRadius: BorderRadius.circular(10),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.black12),
        borderRadius: BorderRadius.circular(10),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
    ),
    validator: (value) {
      if (value == null || value.trim().isEmpty) {
        return '$label is required';
      }
      return null;
    },
  );
}

Widget CustomDropdownField({
  required String label,
  required List<String> items,
  required String? value,
  required void Function(String?) onChanged,
}) {
  return DropdownButtonFormField<String>(
    dropdownColor: Colors.white,
    items: items
        .map((item) => DropdownMenuItem(value: item, child: Text(item)))
        .toList(),
    value: value,
    onChanged: onChanged,
    decoration: InputDecoration(
      label: Text(label),
      labelStyle: const TextStyle(
        overflow: TextOverflow.ellipsis,
      ),
      hintStyle: const TextStyle(
        overflow: TextOverflow.ellipsis,
      ),
      border: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.black12),
        borderRadius: BorderRadius.circular(10),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.black12),
        borderRadius: BorderRadius.circular(10),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
    ),
    validator: (value) {
      if (value == null || value.isEmpty) {
        return '$label is required';
      }
      return null;
    },
  );
}

Future<DateTime?> pickDate(BuildContext context,
    {initialDate, firstDate}) async {
  return showDatePicker(
    context: context,
    initialDate: initialDate ?? DateTime.now(),
    firstDate: firstDate ?? DateTime.now(),
    lastDate: DateTime(2100),
  );
}

Future<TimeOfDay?> pickTime(BuildContext context, {initialTime}) async {
  return showTimePicker(
      context: context, initialTime: initialTime ?? TimeOfDay.now());
}

class CustomDataDisplayTextField extends StatelessWidget {
  final String value;
  final String label;
  final TextEditingController? controller;
  final bool multiline;

  const CustomDataDisplayTextField(
      {super.key,
      required this.value,
      required this.label,
      this.controller,
      this.multiline = false});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: controller == null ? value : null,
      controller: controller,
      readOnly: true,
      maxLines: multiline ? null : 1,
      decoration: InputDecoration(
        label: Text(label),
        labelStyle: const TextStyle(
          overflow: TextOverflow.ellipsis,
        ),
        filled: true,
        fillColor: Colors.grey[200],
        border: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.black12),
          borderRadius: BorderRadius.circular(10),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.black12),
          borderRadius: BorderRadius.circular(10),
        ),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      ),
    );
  }
}
