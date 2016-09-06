import 'package:charted/charted.dart';
import 'kpi_model.dart';
import 'dart:developer';
import 'dart:math' as math;
import 'dart:html' as dom;

//class KpiFocus {
//  static const actual = 'Actual';
//  static const variance = 'Variance';
//  static const percent = 'Percent';
//}

enum KpiFocus { actual, variance, percent }

class InfovizionKpi {
  KpiFocus focus = KpiFocus.actual;
  String selector;
  String maskId = 'delta-Mask';
  bool contrast = false;
  SelectionScope scope;
  Selection svg;
  List<KpiItem> data;
  int width = 4000;
  int height = 4000;
  int spacing = 20;
  int rows;
  int columns;
  int bw, bh;
  InfovizionKpi();
  paint() {
    for (var each in data) {
      each.refresh();
    }
//    debugger();
//    if (height * 1.5 > width) {
//      columns = math.sqrt(data.length).floor();
//      rows = (data.length / columns).floor();
//    } else {
//      columns = (math.sqrt(1.5 * data.length) / 1.5).ceil();
//      rows = (data.length / columns).ceil();
//    }
//    ;

    dom.Element root = dom.querySelector(selector);
    root.children.clear();
    columns = data.length;
    rows = 1;
    // Tile area
    int kx = 0;
    int ky = 0;
    int kw = ((width - 1) / columns).floor();
    int kh = ((height - 1) / rows).floor();
    int cx = (kw / 2).floor();
    int cy = (kh / 2).floor();

    // Background area
    int bx = kx + (spacing / 2).floor();
    int by = ky + (spacing / 2).floor();
    bw = kw - spacing;
    bh = kh - spacing;

    // Responsive drawing area
    int padding = math.min(math.max(2, ((kw - spacing) * 0.025)).floor(), 50);
    int dx = bx + padding;
    int dy = by + padding;
    int dw = bw - padding * 2;
    int dh = bh - padding * 2;

    // Responsive font and path sizes
    int fsCaption = math.min(
        math.min((dh / 6).floor(), (dw / 10).floor()), 24); // Caption font size
    var fsCenter;
    if (focus == KpiFocus.percent) {
      fsCenter = math.max(
          math.min(math.min((dw / 5).floor(), (dh * 0.30).floor()), 50), 6);
    } else {
      fsCenter = math.max(
          math.min(math.min((dw / 6).floor(), (dh * 0.25).floor()), 30), 10);
    }

    num psArrow = math.max(
        math.min((dw / 6).floor(), (dh * 0.25).floor()), 10); // Arrow path size
    num fsBottom = math.min(math.min((dh / 7).floor(), (dw / 12).floor()),
        22); // Bottom caption font size
    String url = dom.window.location.href;
    scope = new SelectionScope.selector(selector);

    svg = scope.append('svg:svg')
      ..attr('position', 'absolute')
      ..attr('x', 0)
      ..attr('y', 0)
      ..attr('width', width)
      ..attr('height', height)
      ..style('font-family', 'qlikview sans')
      ..style('shape-rendering', 'geometricPrecision');

    // =====================================================================================================================
    // Symbols mask definitions
    // =====================================================================================================================
    var defs = svg.append('defs');

    // Variance icon (default)
    (defs.append('mask')
          ..attr('id', maskId)
          ..attr('maskContentUnits', 'objectBoundingBox'))
        .append('polygon')
          ..attr('fill', 'white')
          ..attr('stroke-width', 0)
          ..attr('points', '0,0 0,1 1,0.5');

    Selection tiles = svg.selectAll('.tile').data(data).enter.append('g')
      ..classed('tile')
      ..attrWithCallback(
          'transform',
          (datum, int i, dom.Element element) =>
              'translate(${(kw*(i%columns)).floor()+0.5},${(kh*(i/columns).floor()).floor()+0.5})');
    tiles.append('rect')
      ..attr('x', bx)
      ..attr('y', by)
//        ..attr('rx', properties.rounding)
//        .attr('ry', properties.rounding)
      ..attr('width', bw)
      ..attr('height', bh)
      ..attrWithCallback('fill', deltaColor)
      ..attr('fill-opacity', 1)
      ..attr('stroke-width', 0)
      ..attr('stroke', '#cccccc');

    // =====================================================================================================================
    // Top right caption
    // =====================================================================================================================
    tiles.append('text')
      ..attr('x', dx + dw - 1)
      ..attr('y', dy + fsCaption - 1)
      ..attr('text-anchor', 'end')
      ..attr('font-size', fsCaption.toString() + 'px')
      ..attr('fill', 'white')
      ..textWithCallback((KpiItem d, i, e) {
        String s = d.measureName;
        if (s == '') return '';
        // Truncate long text
        var maxLength = math.max(2, (dw / (fsCaption * 0.6)).floor());
        if (s.length > maxLength) {
          s = s.substring(0, maxLength - 1) + '…';
        }
        return s;
      });

    // =====================================================================================================================
    // Main centered text
    // =====================================================================================================================
    tiles.append('text')
      ..attr('x', dx + dw - 1)
      ..attr('y', cy - 5 + fsCenter / 2)
      ..attr('text-anchor', 'end')
      ..attr('font-size', '${fsCenter}px')
      ..attr('fill', 'white')
      ..textWithCallback((KpiItem d, i, e) {
        switch (focus) {
          case KpiFocus.variance:
            return varianceString(d);
            break;
          case KpiFocus.actual:
            // Show actual amount
            return actualString(d);
            break;
          default:
            // Show %
            return percentString(d);
            break;
        }
      });

    // =====================================================================================================================
    // Icon
    // =====================================================================================================================
    tiles.append('path')
      ..attr('stroke', 'none')
      ..attr('fill', 'white')
      ..attr('d', 'M0 0v ${psArrow}h ${psArrow}v -${psArrow}z')
      ..attr('mask', 'url(#$maskId)')
      ..attrWithCallback('transform', (KpiItem d, i, e) {
        // Step 4 : Translate symbol center to final position
        var transform =
            'translate(${(dx + 3*padding + psArrow/2).floor()},${cy.floor()})';
///         Step 3 : Rotate symbol
        ///
      if (d.percent != null) {
        if (d.percent > (d.neutrality /100)) {
          transform += ' rotate(-90)';
        } else if (d.percent < (-d.neutrality /100)) {
          transform += ' rotate(90)';
        }

      }
        // Step 2 : Scale size
        transform +=
            ' scale(${((psArrow / 2) + ((psArrow * d.size / 100) / 2)) / psArrow})';
        // Step 1 : Translate to symbol center to apply rotation and scale transformations
        transform +=
            ' translate(${(-psArrow / 2).floor()},${(-psArrow / 2).floor()})';
        return transform;
      });
    // Display icon

    // Bottom left & right caption
    if (fsBottom >= 8) {
      // =====================================================================================================================
      // Bottom left caption
      // =====================================================================================================================
      tiles.append('text')
        ..attr('y', dy + dh - 1)
        ..attr('x', dx)
        ..attr('text-anchor', 'start')
        ..attr('font-size', '${fsBottom}px')
        ..attr('fill', 'white')
        ..textWithCallback((KpiItem d, i, e) {
          if (d.measureName == null) {
            return '';
          }
          ;
          if (focus == KpiFocus.percent) {
            return varianceString(d);
          } else {
            // Show %
            return percentString(d);
          }
        });
      // =====================================================================================================================
      // Bottom right caption
      // =====================================================================================================================

      tiles.append('text')
        ..attr('y', dy + dh - 1)
        ..attr('x', dx + dw - 1)
        ..attr('text-anchor', 'end')
        ..attr('font-size', '${fsBottom+2}px')
        ..attr('fill', 'white')
        ..textWithCallback((KpiItem d, i, e) {
          if (d.measureName == null) {
            return '';
          }
          ;
          if (focus == KpiFocus.percent || focus == KpiFocus.variance) {
            return actualString(d);
          } else {
            return varianceString(d);
          }
        });
    }
  }

  num toRound(num value, [int precision = 2]) {
    num multiplier = math.pow(10, precision);
    return (value * multiplier).roundToDouble() / multiplier;
  }

  String toPercent(num value, [int precision = 2]) {
    var multiplier = math.pow(10, precision);
    return (((value + 1) * multiplier * 100).roundToDouble() / multiplier)
            .toString() +
        ' %';
  }

  toAmount(num value, String currency) {
    String unit = '';
    if ((value.abs()) >= 1000000000) {
      value = (value / 100000000).roundToDouble() / 10;
      unit = 'млрд.';
    } else if (value.abs() >= 1000000) {
      value = (value / 100000).roundToDouble() / 10;
      unit = 'мил.';
    } else if (value.abs() >= 1000) {
      value = (value / 100).roundToDouble() / 10;
      unit = 'тыс';
    } else {
      value = (value * 100).roundToDouble() / 100;
    }
    return '$value $unit $currency';
  }

  deltaColor(KpiItem d, i, e) {
//    // Total
//    if ( d.item == 'Σ') return properties.contrast ? '#647687' : '#647687';

    // Discrete
    if ((d.measureName == null) || ((d.valueToCompare ?? 0) == 0))
      return contrast ? '#87794e' : '#bbbbbb';

    // Delta palette
    var invert = d.inverted ? -1 : 1;
    // Positive variance ?
    if (d.percent * invert > (d.neutrality / 100)) {
      // Green
      return contrast ? '#008a00' : '#a4c400';
      // Négative variance ?
    } else if (d.percent * invert < (-d.neutrality / 100)) {
      // Red
      return contrast ? '#a20025' : '#d80073';
      // Neutral zone
    } else {
      // Amber
      // return properties.contrast ? '#fa6800' : '#f0a30a';
      // // Blue
      return contrast ? '#0050ef' : '#1ba1e2';
    }
    ;
  }

  String actualString(KpiItem d) {
    return toAmount(d.actual, d.currency);
  }

  String percentString(KpiItem d) {
    if (d.valueToCompare == 0 || d.percent == null) {
      return (d.actual == 0 ? '0 %' : (d.actual > 0 ? '++ %' : '-- %'));
    }
    if (d.percent >= 10) {
      return '+>>> %';
    } else if (d.percent <= -10) {
      return '-<<< %';
    } else {
      var decimals = 1;
      if (d.percent > 1 || d.percent < -1 || bw <= 125 || bh < 100)
        decimals = 0;
      return (d.percent > 0 ? '+' : '') + toPercent(d.percent, decimals);
    }
  }

  String varianceString(KpiItem d) {
    if (d.variance == null) {
      return '';
    }
    return 'Δ ' +
        (d.variance > 0 ? '+' : '') +
        toAmount(d.variance, d.currency);
  }

//Number.prototype.toMoney = function( currency ) {
//  return this.toLocaleString()+ ' ' + currency ;
//}

}
