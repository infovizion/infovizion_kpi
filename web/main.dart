// Copyright (c) 2016, Vadim Tsushko. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:html';
import 'package:infovizion/kpi/infovizion_kpi.dart';


KpiFocus focus = KpiFocus.actual;
void main() {
  updateKpi();
  querySelector('#actual').onClick.listen((_) {
    focus = KpiFocus.actual;
    updateKpi();
  });
  querySelector('#variance').onClick.listen((_) {
    focus = KpiFocus.variance;
    updateKpi();
  });
  querySelector('#percent').onClick.listen((_) {
    focus = KpiFocus.percent;
    updateKpi();
  });

}


updateKpi() {
  var data = [
    new KpiItem()
      ..actual = 325541
      ..measureName = 'Продажи'
      ..valueToCompare = 298314,
    new KpiItem()
      ..actual = 125154
      ..measureName = 'Наценка'
      ..valueToCompare = 156412,
    new KpiItem()
      ..actual = 948615
      ..measureName = 'Остатки',
//      ..previous = 851642,
    new KpiItem()
      ..actual = 94030
      ..inverted = true
      ..measureName = 'Упущенная прибыль'
      ..valueToCompare = 42751,
    new KpiItem()
      ..actual = 50647
      ..inverted = true
      ..measureName = 'Сумма списаний'
      ..valueToCompare = 70978,

  ];
  var kpi = new InfovizionKpi()
    ..data = data
    ..focus = focus
    ..selector = '.wrapper'
    ..width = (window.innerWidth * 0.99).floor()
    ..height = 150;
  kpi.paint();
  window.onResize.listen((_) {
    kpi.width = (window.innerWidth * 0.99).floor();
    kpi.paint();
  });

}