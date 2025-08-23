import 'package:flutter/material.dart';

class EditorNextButton extends StatelessWidget {
  const EditorNextButton({super.key, required this.onPressed});
  final Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: Align(
        alignment: Alignment.centerRight,
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.only(left: 28, right: 16, top: 10, bottom: 10),
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
          ),
          iconAlignment: IconAlignment.end,
          icon: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.black),
          label: const Text("Next", style: TextStyle(color: Colors.black)),
          onPressed: onPressed,
        ),
      ),
    );
  }
}
