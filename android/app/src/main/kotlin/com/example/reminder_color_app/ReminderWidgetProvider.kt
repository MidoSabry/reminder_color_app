package com.example.reminder_color_app // السطر ده لازم يكون كدا بالظبط

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider
// إضافة الـ Import ده هو اللي هيحل مشكلة الـ R
import com.example.reminder_color_app.R 

class ReminderWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray, widgetData: SharedPreferences) {
        for (appWidgetId in appWidgetIds) {
            // تأكد أن الاسم هنا يطابق اسم الملف في مجلد layout (سواء widget_layout أو reminder_widget)
            val views = RemoteViews(context.packageName, com.example.reminder_color_app.R.layout.reminder_widget).apply {
                
                // استقبال البيانات من فلاتر
                val title = widgetData.getString("title", "No Title")
                val note = widgetData.getString("note", "")
                val date = widgetData.getString("date", "")
                val color = widgetData.getInt("color", 0xFFFFE082.toInt())

                // وضع البيانات في الـ UI
                setTextViewText(R.id.widget_title, title)
                setTextViewText(R.id.widget_note, note)
                setTextViewText(R.id.widget_date, date)
                
                // تغيير لون الخلفية ديناميكياً
                setInt(R.id.widget_container, "setBackgroundColor", color)
            }
            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}