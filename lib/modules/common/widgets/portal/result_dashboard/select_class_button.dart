// lib/widgets/select_class_button.dart
import 'package:flutter/material.dart';
import 'package:linkschool/modules/common/text_styles.dart';


class SelectClassButton extends StatefulWidget {
  final String text;
  final VoidCallback onTap;

  const SelectClassButton({super.key, required this.text, required this.onTap});

  @override
  _SelectClassButtonState createState() => _SelectClassButtonState();
}

class _SelectClassButtonState extends State<SelectClassButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          height: 50,
          decoration: BoxDecoration(
            color: _isHovered ? const Color(0xFF12077B) : Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              widget.text,
              style: AppTextStyles.normal600(
                fontSize: 16,
                color: _isHovered ? Colors.white : Colors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }
}