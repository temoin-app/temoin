package io.github.temoin_app.temoin.service

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.widget.RemoteViews
import io.github.temoin_app.temoin.R
import io.github.temoin_app.temoin.ui.MainActivity

/** Home screen widget: one tap starts filming on a black screen, the interface never shows. */
class DiscreetWidget : AppWidgetProvider() {
    override fun onUpdate(context: Context, manager: AppWidgetManager, ids: IntArray) {
        val intent = MainActivity.quickRecordIntent(context, discreet = true)
        val tap = PendingIntent.getActivity(context, 2, intent, PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT)
        val views = RemoteViews(context.packageName, R.layout.widget_discreet)
        views.setOnClickPendingIntent(R.id.widget_root, tap)
        manager.updateAppWidget(ids, views)
    }
}
