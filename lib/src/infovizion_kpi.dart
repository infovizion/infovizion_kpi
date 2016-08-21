import 'package:charted/charted.dart';
import 'kpi_model.dart';
import 'dart:developer';
import 'dart:math' as math;
import 'dart:html' show Element;

class InfovizionKpi {
  String selector;
  SelectionScope scope;
  Selection svg;
  List<KpiItem> data;
  int width = 4000;
  int height = 4000;
  int spacing = 20;
  int rows;
  int columns;
  InfovizionKpi();
  init() {
//    debugger();
//    if (height * 1.5 > width) {
//      columns = math.sqrt(data.length).floor();
//      rows = (data.length / columns).floor();
//    } else {
//      columns = (math.sqrt(1.5 * data.length) / 1.5).ceil();
//      rows = (data.length / columns).ceil();
//    }
//    ;
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
    int bw = kw - spacing;
    int bh = kh - spacing;

    // Responsive drawing area
    int padding = math.min(math.max(2, ((kw - spacing) * 0.025)).floor(), 50);
    int dx = bx + padding;
    int dy = by + padding;
    int dw = bw - padding * 2;
    int dh = bh - padding * 2;
    scope = new SelectionScope.selector(selector);

    svg = scope.append('svg:svg')
      ..attr('position', 'absolute')
      ..attr('x', 0)
      ..attr('y', 0)
      ..attr('width', width)
      ..attr('height', height)
      ..style('font-family', 'qlikview sans')
      ..style('shape-rendering', 'geometricPrecision');

    var tiles = svg.selectAll('.tile').data(data);

    (tiles.enter.append('g')
          ..classed('tile')
          ..attrWithCallback(
              'transform',
              (datum, int i, Element element) =>
                  'translate(${(kw*(i%columns)).floor()+0.5},${(kh*(i/columns).floor()).floor()+0.5})'
              ))
        .append('rect')
          ..attr('x', bx)
          ..attr('y', by)
//        ..attr('rx', properties.rounding)
//        .attr('ry', properties.rounding)
          ..attr('width', bw)
          ..attr('height', bh)
          ..attr('fill', 'red')
          ..attr('fill-opacity', 1)
          ..attr('stroke-width', 0)
          ..attr('stroke', '#cccccc');

    //.attr('transform', function(d,i) { return 'translate(' + (Math.floor(kw*(i%columns))+0.5) + ',' + (Math.floor(kh*Math.floor(i/columns))+0.5) + ')'; })
    // Selectable area
//        .attr('data-dimensionid', function(d) { return d.dimensionid; })
//        .attr('cursor',cursor)
//        .on('click', clickTile)
    ;
  }
}
