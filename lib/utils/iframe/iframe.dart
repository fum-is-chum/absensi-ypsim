String redrawMaps(double lat1, double long1, double lat2, double long2) {
  // return """
  //   zoom = 19 - ratios.findIndex((d) => d >= D*6);
  //   D = distanceMeter(x1,y1,x2,y2) * 2;
  //   iframe.setAttribute('src', 'https://maps.google.com/maps?q=$lat1,$long1&z=' + zoom + '&output=embed');
  //   document.querySelectorAll('canvas').forEach((node) => node.remove());
  //   x2 = $lat2;
  //   y2 = $long2;
  //   newPoint(x2, y2, radius);
  // """;
  return """
    x1 = $lat1;
    y1 = $long1;

    x2 = $lat2;
    y2 = $long2;

    D = distanceMeter(x1,y1,x2,y2) * 2;
    zoom = 19 - ratios.findIndex((d) => {
      return d >= D*6
    });

    iframe.setAttribute('src', 'https://maps.google.com/maps?q=' + x1 + ',' + y1 + '&z=' + zoom + '&output=embed');
    document.querySelectorAll('canvas').forEach((node) => node.remove());

    newPoint(x2, y2, radius);
    newPoint(x2, y2, 5);
  """;
}