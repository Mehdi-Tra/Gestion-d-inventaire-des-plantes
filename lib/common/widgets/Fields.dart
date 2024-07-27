import 'package:flutter/material.dart';
import 'package:rakcha/common/constants/MyColors.dart';

class TextFeildDynamic extends StatefulWidget {
  final TextEditingController textEditingController;
  final String label;
  final String? Function(String?)? validator;

  const TextFeildDynamic(
      {this.validator,
      required this.label,
      required this.textEditingController,
      super.key});

  @override
  State<TextFeildDynamic> createState() => _TextFeildDynamicState();
}

class _TextFeildDynamicState extends State<TextFeildDynamic> {
  bool checked = true;
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      
      style: const TextStyle(color: MyColors.primeryColor),
      obscureText: widget.label == "password" ? checked : false,
      keyboardType: widget.label == "email"
          ? TextInputType.emailAddress
          : widget.label == "password"
              ? TextInputType.visiblePassword
              : TextInputType.text,
      textAlignVertical: TextAlignVertical.center,
      decoration: _textFieldInputDecoration(),
      controller: widget.textEditingController,
      validator: widget.validator,
    );
  }

  InputDecoration _textFieldInputDecoration() => InputDecoration(
        hintText: widget.label,
        contentPadding: const EdgeInsets.symmetric(vertical: 2, horizontal: 12),
        suffixIcon: widget.label == "password"
            ? IconButton(
                onPressed: () {
                  setState(() {
                    checked = !checked;
                  });
                },
                icon: Icon(
                  checked
                      ? Icons.remove_red_eye_outlined
                      : Icons.remove_red_eye_rounded,
                  color: Theme.of(context).iconTheme.color,
                ),
              )
            : null,
      );
}

class TextFeildForm extends StatefulWidget {
  final TextEditingController? controller;
  final String label;
  final String? defaultValue;
  final int? maxLine;
  final String? Function(String?)? validator;
  final VoidCallback onFocusChange;
  final bool? enable;

  const TextFeildForm(this.maxLine,
      {this.validator,
      this.enable,
      required this.controller,
      required this.defaultValue,
      required this.label,
      required this.onFocusChange,
      super.key});

  @override
  State<TextFeildForm> createState() => _TextFeildFormState();
}

class _TextFeildFormState extends State<TextFeildForm> {
  final FocusNode _focusNode = FocusNode();
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
    if (widget.controller == null) {
      _controller = TextEditingController(text: widget.defaultValue);
    } else {
      _controller = widget.controller!;
      if (widget.defaultValue != null) {
        _controller.text = widget.defaultValue!;
      }
    }
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus) {
      widget.onFocusChange();
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      enabled: widget.enable,
      focusNode: _focusNode,
      validator: widget.validator,
      controller: _controller,
      maxLines: widget.maxLine,
      minLines: 1,
      cursorHeight: 20,
      cursorColor: Colors.amber,
      decoration: InputDecoration(
          contentPadding:
              const EdgeInsets.symmetric(vertical: 2, horizontal: 24),
          // hintText: widget.label,

          label: Text(widget.label),
          labelStyle: Theme.of(context).textTheme.bodyMedium),
    );
  }
}
