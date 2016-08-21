// Copyright (c) 2016, Vadim Tsushko. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:html';
import 'package:infovizion_kpi/infovizion_kpi.dart';

void main() {
  var data = [
    new KpiItem()..actual = 3200,
    new KpiItem()..actual = 3600,
    new KpiItem()..actual = 3100,
  ];
  var kpi = new InfovizionKpi()
    ..data = data
    ..selector = '.wrapper'
    ..width = 800
    ..height = 200;
  kpi.init();
}
