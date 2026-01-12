package com.example.reminder_color_app

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews
import android.graphics.Color
import es.antonborri.home_widget.HomeWidgetPlugin
import org.json.JSONObject


class ReminderWidgetProvider : AppWidgetProvider() {

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)

        if (intent.hasExtra("reminder_id")) {
            val widgetId = intent.getIntExtra(
                AppWidgetManager.EXTRA_APPWIDGET_ID,
                AppWidgetManager.INVALID_APPWIDGET_ID
            )
            val reminderId = intent.getStringExtra("reminder_id") ?: return

            val prefs = HomeWidgetPlugin.getData(context)
            prefs.edit()
                .putString("widget_$widgetId", reminderId)
                .apply()
        }
    }

    override fun onUpdate(
        context: Context,
        manager: AppWidgetManager,
        widgetIds: IntArray
    ) {
        widgetIds.forEach { widgetId ->
            updateSingleWidget(context, manager, widgetId)
        }
    }

   private fun updateSingleWidget(
    context: Context,
    manager: AppWidgetManager,
    widgetId: Int
) {
    val prefs = HomeWidgetPlugin.getData(context)

    // 👇 هنا التغيير
    val reminderId = prefs.getString(
        "widget_$widgetId",
        prefs.getString("last_pinned_reminder_id", null)
    )

    if (reminderId != null) {
        prefs.edit()
            .putString("widget_$widgetId", reminderId)
            .apply()
    }

    val views = RemoteViews(context.packageName, R.layout.reminder_widget_layout)

    val json = reminderId?.let {
        prefs.getString("widget_reminder_$it", null)
    }

    if (json == null) {
        setDefault(views)
        manager.updateAppWidget(widgetId, views)
        return
    }

    val reminder = JSONObject(json)

    views.setTextViewText(R.id.title_text, reminder.getString("title"))
    views.setTextViewText(R.id.note_text, reminder.getString("note"))
    views.setTextViewText(R.id.sticker_text, reminder.getString("sticker"))

    views.setInt(
        R.id.widget_container,
        "setBackgroundColor",
        reminder.getLong("backgroundColor").toInt()
    )

    views.setTextColor(
        R.id.title_text,
        reminder.getLong("textColor").toInt()
    )

    views.setTextColor(
        R.id.note_text,
        reminder.getLong("textColor").toInt()
    )

    manager.updateAppWidget(widgetId, views)
}


    private fun setDefault(views: RemoteViews) {
        views.setTextViewText(R.id.title_text, "No Reminder")
        views.setTextViewText(R.id.note_text, "Pin a reminder")
        views.setTextViewText(R.id.sticker_text, "📌")
    }
}
