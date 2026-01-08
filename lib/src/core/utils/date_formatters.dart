String formatDateTitle(DateTime date) {
  return '${date.month}月${date.day}日, 星期${_weekdayLabel(date.weekday)}';
}

String _weekdayLabel(int weekday) {
  switch (weekday) {
    case DateTime.monday:
      return '一';
    case DateTime.tuesday:
      return '二';
    case DateTime.wednesday:
      return '三';
    case DateTime.thursday:
      return '四';
    case DateTime.friday:
      return '五';
    case DateTime.saturday:
      return '六';
    case DateTime.sunday:
      return '日';
    default:
      return '';
  }
}
