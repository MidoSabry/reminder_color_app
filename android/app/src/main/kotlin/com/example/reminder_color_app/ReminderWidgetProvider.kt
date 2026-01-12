package com.example.reminder_color_app

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.graphics.Color
import android.widget.RemoteViews
import android.util.Log
import android.content.Intent
import es.antonborri.home_widget.HomeWidgetPlugin
import org.json.JSONArray

class ReminderWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        Log.d("ReminderWidget", "🔷 onUpdate called with ${appWidgetIds.size} widgets")
        
        // Get all pinned reminders
        val widgetData = HomeWidgetPlugin.getData(context)
        val remindersJson = widgetData.getString("reminders_list", "[]") ?: "[]"
        
        Log.d("ReminderWidget", "📝 JSON: $remindersJson")
        
        try {
            val remindersArray = JSONArray(remindersJson)
            Log.d("ReminderWidget", "📌 Found ${remindersArray.length()} pinned reminders")
            
            // For each widget, assign a different reminder
            appWidgetIds.forEachIndexed { index, widgetId ->
                val views = RemoteViews(context.packageName, R.layout.reminder_widget_layout)
                
                if (index < remindersArray.length()) {
                    // Show the reminder at this index
                    val reminder = remindersArray.getJSONObject(index)
                    updateViewsWithReminder(views, reminder, context, widgetId)
                } else {
                    // No more reminders, show "Add more reminders"
                    updateViewsWithDefault(views)
                }
                
                appWidgetManager.updateAppWidget(widgetId, views)
                Log.d("ReminderWidget", "✅ Widget $widgetId updated with reminder at index $index")
            }
            
        } catch (e: Exception) {
            Log.e("ReminderWidget", "Error parsing JSON: $e")
            appWidgetIds.forEach { widgetId ->
                val views = RemoteViews(context.packageName, R.layout.reminder_widget_layout)
                updateViewsWithDefault(views)
                appWidgetManager.updateAppWidget(widgetId, views)
            }
        }
    }
    
    private fun updateViewsWithDefault(views: RemoteViews) {
        views.setTextViewText(R.id.title_text, "No More Reminders")
        views.setTextViewText(R.id.note_text, "Add and pin a reminder to see it here!")
        views.setTextViewText(R.id.sticker_text, "📌")
        views.setTextColor(R.id.title_text, Color.parseColor("#1A1A1A"))
        views.setTextColor(R.id.note_text, Color.parseColor("#666666"))
        views.setInt(R.id.widget_container, "setBackgroundColor", Color.parseColor("#E0E0E0"))
    }
    
    private fun updateViewsWithReminder(
        views: RemoteViews,
        reminder: org.json.JSONObject,
        context: Context,
        widgetId: Int
    ) {
        val title = reminder.getString("title")
        val note = reminder.getString("note")
        val sticker = reminder.getString("sticker")
        val bgColorString = reminder.getString("backgroundColor")
        val textColorString = reminder.getString("textColor")
        
        Log.d("ReminderWidget", "  Widget $widgetId -> $sticker $title")
        
        // Parse colors
        val bgColor = try {
            bgColorString.toLong().toInt()
        } catch (e: Exception) {
            Color.parseColor("#FFE082")
        }
        
        val textColor = try {
            textColorString.toLong().toInt()
        } catch (e: Exception) {
            Color.parseColor("#1A1A1A")
        }
        
        // Update views
        views.setTextViewText(R.id.title_text, title)
        views.setTextViewText(R.id.note_text, note)
        views.setTextViewText(R.id.sticker_text, sticker)
        views.setTextColor(R.id.title_text, textColor)
        views.setTextColor(R.id.note_text, textColor)
        views.setInt(R.id.widget_container, "setBackgroundColor", bgColor)
    }

    override fun onEnabled(context: Context) {
        super.onEnabled(context)
        Log.d("ReminderWidget", "🟢 First widget added")
    }

    override fun onDisabled(context: Context) {
        super.onDisabled(context)
        Log.d("ReminderWidget", "🔴 Last widget removed")
    }

    override fun onDeleted(context: Context, appWidgetIds: IntArray) {
        super.onDeleted(context, appWidgetIds)
        Log.d("ReminderWidget", "🗑️ Widgets deleted: ${appWidgetIds.joinToString()}")
    }
}