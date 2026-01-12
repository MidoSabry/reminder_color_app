package com.example.reminder_color_app

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.graphics.Color
import android.widget.RemoteViews
import android.util.Log
import es.antonborri.home_widget.HomeWidgetPlugin

class ReminderWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        Log.d("ReminderWidget", "🔷 onUpdate called with ${appWidgetIds.size} widgets")
        
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.reminder_widget_layout)
            
            // Get data from SharedPreferences
            val widgetData = HomeWidgetPlugin.getData(context)
            val title = widgetData.getString("reminder_title", "No Reminder")
            val note = widgetData.getString("reminder_note", "Tap to add a reminder")
            val sticker = widgetData.getString("reminder_sticker", "⭐")
            val bgColorString = widgetData.getString("reminder_bg_color", "4294951554")
            val textColorString = widgetData.getString("reminder_text_color", "4279834394")
            
            Log.d("ReminderWidget", "📝 Widget Data:")
            Log.d("ReminderWidget", "  Title: $title")
            Log.d("ReminderWidget", "  Note: $note")
            Log.d("ReminderWidget", "  Sticker: $sticker")
            
            // Convert color strings to integers
            val bgColor = try {
                bgColorString?.toLong()?.toInt() ?: Color.parseColor("#FFE082")
            } catch (e: Exception) {
                Log.e("ReminderWidget", "Error parsing bgColor: $e")
                Color.parseColor("#FFE082")
            }
            
            val textColor = try {
                textColorString?.toLong()?.toInt() ?: Color.parseColor("#1A1A1A")
            } catch (e: Exception) {
                Log.e("ReminderWidget", "Error parsing textColor: $e")
                Color.parseColor("#1A1A1A")
            }

            // Update views
            views.setTextViewText(R.id.title_text, title)
            views.setTextViewText(R.id.note_text, note)
            views.setTextViewText(R.id.sticker_text, sticker)
            views.setTextColor(R.id.title_text, textColor)
            views.setTextColor(R.id.note_text, textColor)

            // Set background color
            views.setInt(R.id.widget_container, "setBackgroundColor", bgColor)

            appWidgetManager.updateAppWidget(widgetId, views)
            Log.d("ReminderWidget", "✅ Widget $widgetId updated successfully")
        }
    }

    override fun onEnabled(context: Context) {
        super.onEnabled(context)
        Log.d("ReminderWidget", "🟢 Widget enabled")
    }

    override fun onDisabled(context: Context) {
        super.onDisabled(context)
        Log.d("ReminderWidget", "🔴 Widget disabled")
    }
}