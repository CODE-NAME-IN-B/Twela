import 'package:home_widget/home_widget.dart';

class HomeWidgetService {
  static const String _androidName = 'TwelaWidgetProvider';
  static const String _iOSName = 'TwelaWidget';

  static Future<void> updateWidgets({
    required String balance,
    required String todaySpent,
    required String dailyLimit,
  }) async {
    await HomeWidget.saveWidgetData<String>('balance', balance);
    await HomeWidget.saveWidgetData<String>('today_spent', todaySpent);
    await HomeWidget.saveWidgetData<String>('daily_limit', dailyLimit);
    await HomeWidget.updateWidget(
      androidName: _androidName,
      iOSName: _iOSName,
    );
  }

  static Future<void> registerInteractivityCallback() async {
    HomeWidget.widgetClicked.listen((uri) {
      if (uri.toString() == 'twela://add') {
        // Handle quick add widget click
      }
    });
  }
}
