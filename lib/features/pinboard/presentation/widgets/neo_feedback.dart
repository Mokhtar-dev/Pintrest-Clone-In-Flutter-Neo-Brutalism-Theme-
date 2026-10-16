import 'package:flutter/material.dart';

const Color kNeoBlack = Color(0xFF0F1110);
const Color kNeoPanel = Color(0xFF161A18);
const Color kNeoLime = Color(0xFFB6FF00);
const Color kNeoRed = Color(0xFFFF0055);
const Color kNeoYellow = Color(0xFFFFF500);
const Color kNeoCyan = Color(0xFF00E5FF);

/// Terminal style snackbar used for all in-app feedback.
void showNeoTip(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            color: kNeoLime,
            fontWeight: FontWeight.w900,
            fontSize: 11,
            letterSpacing: 1.0,
          ),
        ),
        backgroundColor: kNeoPanel,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: kNeoLime, width: 1.5),
        ),
      ),
    );
}

/// Modal bottom sheet styled with the neo brutalism terminal skin.
Future<T?> showNeoSheet<T>(
  BuildContext context, {
  required String title,
  required Widget child,
}) {
  return showModalBottomSheet<T>(
    context: context,
    backgroundColor: kNeoPanel,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      side: BorderSide(color: kNeoLime, width: 1.5),
    ),
    builder: (sheetContext) {
      return Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(width: 8, height: 8, color: kNeoLime),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(sheetContext),
                  child: const Icon(Icons.close, color: Colors.white54, size: 18),
                ),
              ],
            ),
            const SizedBox(height: 14),
            child,
          ],
        ),
      );
    },
  );
}

/// Text input matching the terminal panel style used on the auth screens.
Widget neoTextField({
  required TextEditingController controller,
  String? hint,
  bool autofocus = false,
  int maxLines = 1,
  TextInputType? keyboardType,
}) {
  return Container(
    decoration: BoxDecoration(
      color: kNeoBlack,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.white24, width: 1.5),
    ),
    child: TextField(
      controller: controller,
      autofocus: autofocus,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white, fontSize: 13),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white38, fontSize: 12),
        border: InputBorder.none,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    ),
  );
}

/// Full width lime action button with the terminal styling.
Widget neoPrimaryButton({
  required String label,
  required VoidCallback onTap,
  bool busy = false,
}) {
  return GestureDetector(
    onTap: busy ? null : onTap,
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: kNeoLime,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: busy
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.black,
                ),
              )
            : Text(
                label,
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                  letterSpacing: 1.0,
                ),
              ),
      ),
    ),
  );
}

/// Empty state block mirroring the original "SYSTEM MODULE INITIALIZING..."
/// placeholder look.
class NeoEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const NeoEmptyState({
    super.key,
    this.icon = Icons.bolt,
    required this.title,
    this.subtitle = 'SYSTEM MODULE INITIALIZING...',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: kNeoLime, size: 48),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 18,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white38, fontSize: 11),
          ),
        ],
      ),
    );
  }
}
