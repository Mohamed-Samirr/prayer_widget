package com.example.prayer_widget

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin

class PrayerWidgetProvider : AppWidgetProvider() {

    companion object {
        const val ACTION_REFRESH = "com.example.prayer_widget.ACTION_REFRESH"
    }

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
        if (intent.action == ACTION_REFRESH || intent.action == AppWidgetManager.ACTION_APPWIDGET_UPDATE) {
            val appWidgetManager = AppWidgetManager.getInstance(context)
            val componentName = ComponentName(context, PrayerWidgetProvider::class.java)
            val appWidgetIds = appWidgetManager.getAppWidgetIds(componentName)
            if (appWidgetIds != null && appWidgetIds.isNotEmpty()) {
                onUpdate(context, appWidgetManager, appWidgetIds)
            }
        }
    }

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        val widgetData = try {
            HomeWidgetPlugin.getData(context)
        } catch (e: Exception) {
            context.getSharedPreferences("HomeWidgetPreferences", Context.MODE_PRIVATE)
        }

        val location = widgetData.getString("widget_location", "Cairo, Egypt") ?: "Cairo, Egypt"
        val nextPrayer = widgetData.getString("widget_next_prayer_name", "Fajr") ?: "Fajr"
        val nextPrayerTime = widgetData.getString("widget_next_prayer_time", "--:--") ?: "--:--"
        val activePrayer = (widgetData.getString("widget_active_prayer", "fajr") ?: "fajr").lowercase()

        // Calculate dynamic real-time countdown upon refresh
        val targetEpochStr = widgetData.getString("widget_next_prayer_epoch", null)
        val targetEpoch = targetEpochStr?.toLongOrNull() ?: 0L
        val countdown = if (targetEpoch > 0L) {
            val now = System.currentTimeMillis()
            val diff = targetEpoch - now
            if (diff > 0) {
                val hours = (diff / (1000 * 60 * 60)).toString().padStart(2, '0')
                val minutes = ((diff / (1000 * 60)) % 60).toString().padStart(2, '0')
                val seconds = ((diff / 1000) % 60).toString().padStart(2, '0')
                "$hours:$minutes:$seconds"
            } else {
                "Time for prayer"
            }
        } else {
            widgetData.getString("widget_countdown", "") ?: ""
        }

        val fajr = widgetData.getString("widget_fajr_time", "--:--") ?: "--:--"
        val dhuhr = widgetData.getString("widget_dhuhr_time", "--:--") ?: "--:--"
        val asr = widgetData.getString("widget_asr_time", "--:--") ?: "--:--"
        val maghrib = widgetData.getString("widget_maghrib_time", "--:--") ?: "--:--"
        val isha = widgetData.getString("widget_isha_time", "--:--") ?: "--:--"

        val goldColor = Color.parseColor("#D4AF37")
        val tertiaryColor = Color.parseColor("#636366")
        val secondaryColor = Color.parseColor("#8E8E93")

        for (appWidgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.prayer_widget_layout)

            // Header info
            views.setTextViewText(R.id.widget_location, location)
            val badgeText = if (countdown.isNotEmpty()) "$nextPrayer in $countdown" else "Upcoming: $nextPrayer"
            views.setTextViewText(R.id.widget_countdown_badge, badgeText)

            // Hero center
            views.setTextViewText(R.id.widget_next_prayer_name, nextPrayer)
            views.setTextViewText(R.id.widget_next_prayer_time, nextPrayerTime)

            // 5 Prayers bottom row
            views.setTextViewText(R.id.widget_fajr_time, fajr)
            views.setTextViewText(R.id.widget_dhuhr_time, dhuhr)
            views.setTextViewText(R.id.widget_asr_time, asr)
            views.setTextViewText(R.id.widget_maghrib_time, maghrib)
            views.setTextViewText(R.id.widget_isha_time, isha)

            // Highlight active prayer column
            fun updatePrayerCol(colId: Int, nameId: Int, timeId: Int, isCurrent: Boolean) {
                if (isCurrent) {
                    views.setInt(colId, "setBackgroundResource", R.drawable.widget_active_pill)
                    views.setTextColor(nameId, goldColor)
                    views.setTextColor(timeId, goldColor)
                } else {
                    views.setInt(colId, "setBackgroundResource", R.drawable.widget_inactive_pill)
                    views.setTextColor(nameId, tertiaryColor)
                    views.setTextColor(timeId, secondaryColor)
                }
            }

            updatePrayerCol(R.id.prayer_col_fajr, R.id.text_name_fajr, R.id.widget_fajr_time, activePrayer == "fajr")
            updatePrayerCol(R.id.prayer_col_dhuhr, R.id.text_name_dhuhr, R.id.widget_dhuhr_time, activePrayer == "dhuhr")
            updatePrayerCol(R.id.prayer_col_asr, R.id.text_name_asr, R.id.widget_asr_time, activePrayer == "asr")
            updatePrayerCol(R.id.prayer_col_maghrib, R.id.text_name_maghrib, R.id.widget_maghrib_time, activePrayer == "maghrib")
            updatePrayerCol(R.id.prayer_col_isha, R.id.text_name_isha, R.id.widget_isha_time, activePrayer == "isha")

            // 1) Tap on refresh button -> Triggers ACTION_REFRESH to immediately re-calculate countdown
            val refreshIntent = Intent(context, PrayerWidgetProvider::class.java).apply {
                action = ACTION_REFRESH
            }
            val refreshPendingIntent = PendingIntent.getBroadcast(
                context,
                101,
                refreshIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            views.setOnClickPendingIntent(R.id.widget_btn_refresh, refreshPendingIntent)

            // 2) Tap on root widget -> Opens Flutter application
            val launchIntent = Intent(context, MainActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            }
            val launchPendingIntent = PendingIntent.getActivity(
                context,
                0,
                launchIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            views.setOnClickPendingIntent(R.id.widget_root, launchPendingIntent)

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
