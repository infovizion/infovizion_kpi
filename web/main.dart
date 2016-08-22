// Copyright (c) 2016, Vadim Tsushko. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:html';
import 'package:infovizion_kpi/infovizion_kpi.dart';

void main() {
  var data = [
    new KpiItem()
      ..actual = 3200
      ..measureName = 'Продажи'
      ..previous = 2900,
    new KpiItem()
      ..actual = 3600
      ..measureName = 'Наценка'
      ..previous = 3500,
    new KpiItem()
      ..actual = 3100
      ..measureName = 'Остатки'
      ..previous = 3500,
    new KpiItem()
      ..actual = 1200
      ..measureName = 'Упущенная прибыль'
      ..previous = 2500,
  ];
  var kpi = new InfovizionKpi()
    ..data = data
    ..selector = '.wrapper'
    ..width = (window.innerWidth * 0.99).floor()
    ..height = 200;
  kpi.paint();
  window.onResize.listen((_) {

    kpi.width = (window.innerWidth * 0.99).floor();
    kpi.paint();
  });
}
