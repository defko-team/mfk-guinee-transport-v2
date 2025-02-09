import 'package:flutter/material.dart';
import 'package:mfk_guinee_transport/helper/constants/colors.dart';

class BookingConfirmationDialog extends StatelessWidget {
  final Future<void> Function()? book;
  final String displayText;
  const BookingConfirmationDialog(
      {super.key,
      required this.book,
      this.displayText =
          'Votre réservation a été confirmée. Le chauffeur viendra vous chercher dans 2 minutes.'});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      backgroundColor: AppColors.white,
      child: Container(
        padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle,
              color: AppColors.green,
              size: 50,
            ),
            const SizedBox(height: 16.0),
            const Text(
              'Réservé avec succes',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20.0,
              ),
            ),
            const SizedBox(height: 8.0),
            Container(
              padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
              child: Text(
                displayText,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15.0,
                  color: AppColors.grey,
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            const Divider(
              thickness: 0.4,
              color: AppColors.grey,
              height: 1.0,
            ),
            IntrinsicHeight(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text(
                        'Annuler',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                  const VerticalDivider(
                    thickness: 0.4,
                    color: AppColors.grey,
                  ),
                  Expanded(
                    child: TextButton(
                      onPressed: () async {
                        if (book != null) {
                          await book!();
                        }
                        Navigator.of(context).pop();
                      },
                      child: const Text(
                        'Fait',
                        style: TextStyle(color: Colors.green),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
