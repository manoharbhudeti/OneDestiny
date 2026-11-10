import 'package:flutter/material.dart';

import '../models/vendor_model.dart';
import '../state/app_state_scope.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Opens a popup that collects venue, event date, and location before booking.
Future<bool> showBookingRequestDialog(BuildContext context, VendorModel vendor) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => BookingRequestDialog(vendor: vendor),
  ).then((booked) => booked ?? false);
}

class BookingRequestDialog extends StatefulWidget {
  final VendorModel vendor;

  const BookingRequestDialog({
    super.key,
    required this.vendor,
  });

  @override
  State<BookingRequestDialog> createState() => _BookingRequestDialogState();
}

class _BookingRequestDialogState extends State<BookingRequestDialog> {
  final _formKey = GlobalKey<FormState>();
  final _venueController = TextEditingController();
  final _locationController = TextEditingController();
  DateTime? _eventDate;
  bool _submitting = false;
  String? _errorText;

  @override
  void dispose() {
    _venueController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_submitting) return;
    if (!_formKey.currentState!.validate()) return;

    final selected = _eventDate;
    if (selected == null) {
      setState(() => _errorText = 'Select an event date.');
      return;
    }
    final eventDate = DateTime(selected.year, selected.month, selected.day);

    setState(() {
      _submitting = true;
      _errorText = null;
    });

    final error = await AppStateScope.read(context).createBookingForVendor(
      widget.vendor,
      eventDate: eventDate,
      venue: _venueController.text.trim(),
      location: _locationController.text.trim(),
    );

    if (!mounted) return;
    if (error != null) {
      setState(() {
        _submitting = false;
        _errorText = error;
      });
      return;
    }

    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final primary = Theme.of(context).colorScheme.primary;

    return Dialog(
      backgroundColor: surface,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: AppColors.accentGold.withValues(alpha: isDark ? 0.35 : 0.25)),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(22, 22, 22, 18 + MediaQuery.viewInsetsOf(context).bottom),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Book ${widget.vendor.name}', style: AppTypography.heading(context).copyWith(fontSize: 18)),
              const SizedBox(height: 6),
              Text(
                'Share the venue, event date, and location for this booking.',
                style: AppTypography.description(context, isSecondary: true),
              ),
              const SizedBox(height: 18),
              _BookingField(
                controller: _venueController,
                label: 'Venue',
                hint: 'Palace lawns, banquet hall',
                icon: Icons.apartment_rounded,
                border: border,
                validator: (value) => _required(value, 'Venue'),
              ),
              const SizedBox(height: 14),
              Text('Event date', style: AppTypography.subtitle(context)),
              const SizedBox(height: 4),
              Text(
                _eventDate == null
                    ? 'Tap a date on the calendar.'
                    : 'Selected ${_eventDate!.day}/${_eventDate!.month}/${_eventDate!.year}',
                style: AppTypography.description(
                  context,
                  isSecondary: _eventDate == null,
                ).copyWith(color: _eventDate == null ? null : AppColors.accentGold),
              ),
              const SizedBox(height: 8),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCardBg : AppColors.lightBackground,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: border),
                ),
                child: CalendarDatePicker(
                  initialDate: _eventDate ?? DateTime.now().add(const Duration(days: 1)),
                  firstDate: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day),
                  lastDate: DateTime(DateTime.now().year + 3),
                  onDateChanged: _submitting
                      ? (_) {}
                      : (date) {
                          setState(() {
                            _eventDate = DateTime(date.year, date.month, date.day);
                            _errorText = null;
                          });
                        },
                ),
              ),
              const SizedBox(height: 12),
              _BookingField(
                controller: _locationController,
                label: 'Location',
                hint: 'Hyderabad, Jubilee Hills',
                icon: Icons.location_on_outlined,
                border: border,
                validator: (value) => _required(value, 'Location'),
              ),
              if (_errorText != null) ...[
                const SizedBox(height: 12),
                Text(
                  _errorText!,
                  style: AppTypography.description(context).copyWith(color: AppColors.error),
                ),
              ],
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _submitting ? null : () => Navigator.of(context).pop(false),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: primary,
                        side: BorderSide(color: border),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _submitting ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: _submitting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Text('Submit'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _required(String? value, String label) {
    if (value == null || value.trim().isEmpty) return '$label is required.';
    return null;
  }
}

class _BookingField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final Color border;
  final String? Function(String?) validator;

  const _BookingField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    required this.border,
    required this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      textInputAction: TextInputAction.next,
      style: AppTypography.description(context).copyWith(fontSize: 14),
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, size: 20, color: AppColors.accentGold),
        filled: true,
        fillColor: Theme.of(context).brightness == Brightness.dark
            ? AppColors.darkCardBg
            : AppColors.lightBackground,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: border)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: border)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.accentGold),
        ),
      ),
    );
  }
}
