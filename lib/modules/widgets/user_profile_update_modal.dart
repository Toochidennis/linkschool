import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:linkschool/modules/model/cbt_user_model.dart';
import 'package:url_launcher/url_launcher.dart';

class UserProfileUpdateModal extends StatefulWidget {
  final Future<void> Function({
    required String phone,
    required String gender,
    required String birthDate, // ISO: YYYY-MM-DD
  }) onSave;
  final CbtUserModel? user;

   const UserProfileUpdateModal({Key? key, required this.onSave, this.user})
      : super(key: key);

  /// Call this instead of showDialog + AlertDialog
  static Future<void> show(
    BuildContext context, {
    required Future<void> Function({
      required String phone,
      required String gender,
      required String birthDate,

    }) onSave,
    CbtUserModel? user,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => UserProfileUpdateModal(onSave: onSave, user: user),
    );
  }

  @override
  State<UserProfileUpdateModal> createState() => _UserProfileUpdateModalState();
}

class _UserProfileUpdateModalState extends State<UserProfileUpdateModal> {
  final _formKey = GlobalKey<FormState>();

  final _phoneController = TextEditingController();
  final _otherGenderController = TextEditingController();

  bool _privacyAccepted = false;
  static final Uri _privacyPolicyUri =
      Uri.parse('https://linkschoolonline.com/privacy-policy');

  String? _selectedGender;
  DateTime? _birthDate;

  bool _isSaving = false;

  static const _genderOptions = <String>[
    'male',
    'female',
    "others"
  ];

  @override
  void dispose() {
    _phoneController.dispose();
    _otherGenderController.dispose();
    super.dispose();
  }

  String _toIsoDate(DateTime d) => DateFormat('yyyy-MM-dd').format(d);
  String _displayDate(DateTime d) => DateFormat('dd MMM, yyyy').format(d);

  Future<void> _pickBirthDate() async {
    FocusScope.of(context).unfocus();

    final now = DateTime.now();
    final initial = _birthDate ?? DateTime(now.year - 16, now.month, now.day);

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1900, 1, 1),
      lastDate: now,
      helpText: 'Select birth date',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            useMaterial3: true,
            dialogTheme:  DialogThemeData(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) setState(() => _birthDate = picked);
  }




  Future<void> _submit() async {
    if (!_privacyAccepted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('Please agree to the privacy policy before saving your profile.'),
          ),
        );
      }
      return;
    }

    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSaving = true);

    try {
      final phone = _phoneController.text.trim();

      final gender = (_selectedGender == 'Other')
          ? _otherGenderController.text.trim()
          : (_selectedGender ?? '').trim();

      final birthDateIso = _toIsoDate(_birthDate!);
      print("Submitting profile: $phone, $gender, $birthDateIso");

      await widget.onSave(phone: phone, gender: gender, birthDate: birthDateIso);
      Navigator.of(context).pop();
    } catch (e) {
      // Handle error if needed
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save profile: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _launchPrivacyPolicy() async {
    try {
      if (await canLaunchUrl(_privacyPolicyUri)) {
        await launchUrl(_privacyPolicyUri, mode: LaunchMode.externalApplication);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open privacy policy.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error opening privacy policy: $e')),
        );
      }
    }
  }

  InputDecoration _decor({
    required String label,
    required IconData icon,
    String? hint,
    Widget? suffix,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon),
      suffixIcon: suffix,
      filled: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isOther = _selectedGender == 'Other';

    // Dialog width that stays aligned across screens
    final maxWidth = 440.0;
    final privacyTextStyle = theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ) ??
        TextStyle(color: theme.colorScheme.onSurfaceVariant);
    final privacyLinkStyle = privacyTextStyle.copyWith(
      color: theme.colorScheme.primary,
      fontWeight: FontWeight.w600,
      decoration: TextDecoration.underline,
    );

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: SingleChildScrollView(
            child: Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 20,
                    spreadRadius: 0,
                    offset: const Offset(0, 10),
                    color: Colors.black.withOpacity(0.18),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ===== Header (aligned) =====
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(18, 16, 10, 12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        border: Border(
                          bottom: BorderSide(
                            color: theme.colorScheme.outlineVariant,
                          ),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                              Text(
                                'Complete your profile',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                                const SizedBox(height: 4),
                                Text(
                                  'Add a few details to finish setup.',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ===== Body =====
                    Padding(
                      padding: const EdgeInsets.fromLTRB(18, 16, 18, 10),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Phone number field
                              // explanation text
                            Text(
                              "Phone",
                              style:TextStyle(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w600,
                                fontSize:20,
                              )
                            ),
                            TextFormField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              textInputAction: TextInputAction.next,
                              decoration: _decor(
                                label: 'Phone number',
                                icon: Icons.phone_outlined,
                                hint: 'e.g. +234 801 234 5678',
                              ),
                              validator: (v) {
                                final value = (v ?? '').trim();
                                if (value.isEmpty) return 'Enter phone number';
                                if (value.length < 7) return 'Enter a valid phone number';
                                return null;
                              },
                            ),
                            const SizedBox(height: 25),
                            // Gender field
                            // the explanation text
                            Text(
                              'Gender',
                                style:TextStyle(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w600,
                                fontSize:20,
                              )
                            ),
                            DropdownButtonFormField<String>(
                              value: _selectedGender,
                              items: _genderOptions
                                  .map((g) => DropdownMenuItem(
                                        value: g,
                                        child: Text(g),
                                      ))
                                  .toList(),
                              onChanged: (v) {
                                setState(() {
                                  _selectedGender = v;
                                  if (v != 'Other') _otherGenderController.clear();
                                });
                              },
                              decoration: _decor(
                                label: 'Gender',
                                icon: Icons.person_outline,
                              ),
                              validator: (v) {
                                if ((v ?? '').isEmpty) return 'Select gender';
                                if (v == 'Other' &&
                                    _otherGenderController.text.trim().isEmpty) {
                                  return 'Enter your gender';
                                }
                                return null;
                              },
                            ),

                            if (isOther) ...[
                              const SizedBox(height: 25),
                              TextFormField(
                                controller: _otherGenderController,
                                textInputAction: TextInputAction.next,
                                decoration: _decor(
                                  label: 'Specify gender',
                                  icon: Icons.edit_outlined,
                                ),
                                validator: (v) {
                                  if (!isOther) return null;
                                  if ((v ?? '').trim().isEmpty) return 'Enter your gender';
                                  return null;
                                },
                              ),
                            ],

                            const SizedBox(height: 25),
                            // explanation text
                            Row(
                              children: [
                                Text(
                                  'Birth Date',
                                    style:TextStyle(
                                    color:theme.colorScheme.primary,
                                    fontWeight: FontWeight.w600,
                                    fontSize:20,
                                  )
                                ),
                                const SizedBox(width: 6),
                                Icon(
                                  Icons.info_outline,
                                  size: 16,
                                  color: theme.colorScheme.primary,
                                ),
                              ],
                            ),
                            Text(
                              'We use this to personalize your account.',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            // Birthdate field (tap container)
                            InkWell(
                              borderRadius: BorderRadius.circular(14),
                              onTap: _pickBirthDate,
                              child: IgnorePointer(
                                child: TextFormField(
                                  readOnly: true,
                                  controller: TextEditingController(
                                    text: _birthDate == null
                                        ? ''
                                        : _displayDate(_birthDate!),
                                  ),
                                  decoration: _decor(
                                    label: 'Birth date',
                                    icon: Icons.cake_outlined,
                                    hint: 'Select date',
                                    suffix: const Icon(Icons.calendar_month_outlined),
                                  ),
                                  validator: (_) {
                                    if (_birthDate == null) return 'Select birth date';
                                    return null;
                                  },
                                ),
                              ),
                            ),

                            const SizedBox(height: 25),

                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Checkbox(
                                  value: _privacyAccepted,
                                  onChanged: (checked) {
                                    setState(() {
                                      _privacyAccepted = checked ?? false;
                                    });
                                  },
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Wrap(
                                    crossAxisAlignment: WrapCrossAlignment.center,
                                    runSpacing: 2,
                                    children: [
                                      Text(
                                        'I agree to the ',
                                        style: privacyTextStyle,
                                      ),
                                      TextButton(
                                        onPressed: _launchPrivacyPolicy,
                                        style: TextButton.styleFrom(
                                          padding: EdgeInsets.zero,
                                          minimumSize: const Size(0, 0),
                                          tapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                        ),
                                        child: Text(
                                          'Privacy Policy',
                                          style: privacyLinkStyle,
                                        ),
                                      ),
                                      Text(
                                        ' and confirm my details are accurate.',
                                        style: privacyTextStyle,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            
                          ],
                        ),
                      ),
                    ),

                    // ===== Footer actions (aligned) =====
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(18, 10, 18, 16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        border: Border(
                          top: BorderSide(color: theme.colorScheme.outlineVariant),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.of(context).pop(),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: const Text('Cancel'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                          child: FilledButton(
                            onPressed:
                                (_isSaving || !_privacyAccepted) ? null : _submit,
                              style: FilledButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: _isSaving
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    )
                                  : const Text('Save'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
