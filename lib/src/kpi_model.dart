class KpiItem {
  String measureName;
  num actual = 0;
  num valueToCompare;
  num variance;
  num percent;
  num size = 100;
  bool selected = false;
  bool inverted = false;
  num neutrality = 10;
  String currency = 'р.';
  refresh() {
    if (valueToCompare != null) {
      variance = actual - valueToCompare;
      percent = valueToCompare != 0 ? (actual - valueToCompare) / valueToCompare.abs() : null;
    }
  }
}
