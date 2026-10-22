import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/prayer_data.dart';
import '../theme/app_theme.dart';

class PrayerTile extends StatelessWidget {
  final PrayerItem prayer;

  const PrayerTile({
    super.key,
    required this.prayer,
  });

  IconData _getIconForPrayer(PrayerType type) {
    switch (type) {
      case PrayerType.fajr:
        return Icons.nights_stay_outlined;
      case PrayerType.sunrise:
        return Icons.wb_twilight_rounded;
      case PrayerType.dhuhr:
        return Icons.wb_sunny_rounded;
      case PrayerType.asr:
        return Icons.sunny_snowing;
      case PrayerType.maghrib:
        return Icons.wb_twilight_outlined;
      case PrayerType.isha:
        return Icons.bedtime_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isNext = prayer.isNext;
    final isPast = prayer.isPast;

    final Color cardBg = isNext ? const Color(0xFF191815) : AppColors.surface;
    final Color borderColor = isNext ? AppColors.borderActive : AppColors.border;
    final Color titleColor = isNext
        ? AppColors.textPrimary
        : (isPast ? AppColors.textTertiary : AppColors.textPrimary);
    final Color timeColor = isNext
        ? AppColors.gold
        : (isPast ? AppColors.textTertiary : AppColors.textPrimary);
    final Color iconColor = isNext
        ? AppColors.gold
        : (isPast ? AppColors.textMuted : AppColors.textSecondary);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: borderColor,
          width: 1,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          // Prayer icon with subtle background
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: isNext ? AppColors.goldSubtleBg : AppColors.surfaceSubtle,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isNext ? AppColors.borderActive : AppColors.borderSubtle,
                width: 1,
              ),
            ),
            child: Icon(
              _getIconForPrayer(prayer.type),
              color: iconColor,
              size: 18,
            ),
          ),

          const SizedBox(width: 14),

          // English + Arabic Names
          Expanded(
            child: Row(
              children: [
                Text(
                  prayer.englishName,
                  style: GoogleFonts.inter(
                    color: titleColor,
                    fontSize: 15,
                    fontWeight: isNext ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  prayer.arabicName,
                  style: GoogleFonts.inter(
                    color: isNext ? AppColors.goldMuted : AppColors.textTertiary,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                if (isNext) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.goldSubtleBg,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: AppColors.borderActive,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      'NEXT',
                      style: GoogleFonts.inter(
                        color: AppColors.gold,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Scheduled Time and Relative status
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                prayer.formattedTime,
                style: GoogleFonts.inter(
                  color: timeColor,
                  fontSize: 15,
                  fontWeight: isNext ? FontWeight.w700 : FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                prayer.relativeTime,
                style: GoogleFonts.inter(
                  color: isNext ? AppColors.goldMuted : AppColors.textTertiary,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
