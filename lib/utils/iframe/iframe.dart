import 'package:geolocator/geolocator.dart';

String redrawMaps(double lat1, double long1, double lat2, double long2, int radius) {
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

    radius = $radius * 2;

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

String map() {
  return """
    <html>
  <head>
    <title>Add Map</title>
    <meta name="referrer" content="no-referrer"> 
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <script src="https://polyfill.io/v3/polyfill.min.js?features=default"></script>

    <!-- <link rel="stylesheet" type="text/css" href="./style.css" /> -->
    <!-- <script type="module" src="./index.js"></script> -->
    <style>
      *{
        box-sizing: border-box;
      }
      html,body{
        margin: 0;
      }
      #map {
        height: 100%;
        /* The height is 400 pixels */
        width: 100%;
        /* The width is the width of the web page */
      }
    </style>
  </head>
  <body>
    <!--The div element for the map -->
    <div id="map"></div>

    <!-- 
     The `defer` attribute causes the callback to execute after the full HTML
     document has been parsed. For non-blocking uses, avoiding race conditions,
     and consistent behavior across browsers, consider loading using Promises
     with https://www.npmjs.com/package/@googlemaps/js-api-loader.
    -->
    <script
      src="https://maps.googleapis.com/maps/api/js?key=&callback=initMap"
      defer
    ></script>
  """;
}

String bypass() {
  return r"""// hack Google Maps to bypass API v3 key (needed since 22 June 2016 http://googlegeodevelopers.blogspot.com.es/2016/06/building-for-scale-updates-to-google.html)
    var target = document.head;
      var observer = new MutationObserver(function(mutations) {
          for (var i = 0; mutations[i]; ++i) { // notify when script to hack is added in HTML head
            if(mutations[i].addedNodes.length > 0) {
              if (mutations[i].addedNodes[0].nodeName == "SCRIPT" && mutations[i].addedNodes[0].src.match(/\/AuthenticationService.Authenticate?/g) || mutations[i].addedNodes[0].src.match(/\/QuotaService.RecordEvent?/g)) {
                  var str = mutations[i].addedNodes[0].src.match(/[?&]callback=.*[&$]/g);
                  if (str) {
                      if (str[0][str[0].length - 1] == '&') {
                          str = str[0].substring(10, str[0].length - 1);
                      } else {
                          str = str[0].substring(10);
                      }
                      var split = str.split(".");
                      var object = split[0];
                      var method = split[1];
                      window[object][method] = null; // remove censorship message function _xdc_._jmzdv6 (AJAX callback name "_jmzdv6" differs depending on URL)
                      window[object] = {}; // when we removed the complete object _xdc_, Google Maps tiles did not load when we moved the map with the mouse (no problem with OpenStreetMap)
                  }
                  // observer.disconnect();
              }
            }
          }
      });
      var config = { attributes: true, childList: true, characterData: true }
      observer.observe(target, config);""";
}

String updatePosition(Position pos, Map<String, dynamic> target) {
  return """
    try {
        coordinates[0] = {
        lat: ${pos.latitude},
        lng: ${pos.longitude}
      }

      coordinates[1] = {
        lat: ${target['latitude']},
        lng: ${target['longitude']}
      }
      document.dispatchEvent(new Event(POSITION_UPDATE));
    } catch (e) {
      alert(e);
    }
  """;
}

String homeMap(Position pos1, double lat2, double lng2, int radius) {
  return map() + """
    <script>
      const POSITION_UPDATE = 'position-update';
      // Initialize and add the map
      const coordinates = [
        { lat: ${pos1.latitude}, lng: ${pos1.longitude} },
        { lat: $lat2, lng: $lng2 }
      ]; 
      function initMap() {
        const map = new google.maps.Map(document.getElementById("map"), {
          zoom: 15,
        });

        const markerBounds = new google.maps.LatLngBounds();
        const markers = []

        coordinates.forEach((coordinate, idx) => {
          const marker = new google.maps.Marker({
            position: coordinate,
            map: map,
            animation: idx == 0 ? null : google.maps.Animation.DROP,
            icon: idx == 1 ? null : 
              {
                path: google.maps.SymbolPath.CIRCLE,
                fillColor: '#4485f4',
                fillOpacity: 1,
                strokeColor: '#FFF',
                strokeOpacity: 0.9,
                strokeWeight: 2,
                scale: 7
              }
          });
          
          markerBounds.extend(coordinate);
          markers.push(marker);
        })

        const targetRadius = new google.maps.Circle({
          map: map,
          radius: $radius,
          strokeColor: '#000000',
          strokeOpacity: 0.5,
          strokeWeight: 2,
          fillColor: '#000000',
          fillOpacity: 0.2,
          center: coordinates[1]
        })

        map.fitBounds(markerBounds);

        // lacak perubahan posisi
        const event = new Event(POSITION_UPDATE);

        document.addEventListener(POSITION_UPDATE, () => {
          const newMarkerbounds = new google.maps.LatLngBounds();
          coordinates.forEach((coordinate, idx) => {
            markers[idx].setPosition(coordinate);
            newMarkerbounds.extend(coordinate);
          })
          targetRadius.setPosition(coordinates[0]);
          map.fitBounds(markerBounds);
        })
      }
      window.initMap = initMap;
      """ + bypass() + """
    </script>
  </body>
</html>
    """;
}

String detailPresensiMap(double? lat1, double? lng1, double? lat2, double? lng2) {
  return map() + """
    <script>
     // Initialize and add the map
     function initMap() {
        const coordinates = [
          { lat: $lat1, lng: $lng1 },
          { lat: $lat2, lng: $lng2 }
        ]""" + r"""

        const map = new google.maps.Map(document.getElementById("map"), {
          zoom: 15,
        });

        var markerBounds = new google.maps.LatLngBounds();

        coordinates.forEach((coordinate, idx) => {
          if(coordinate.lat && coordinate.lng) {
            const marker = new google.maps.Marker({
              position: coordinate,
              map: map,
              animation: google.maps.Animation.DROP
            });
            
            new google.maps.InfoWindow({
              position: coordinate,
              content: `<h5>${idx == 0 ? 'Check In' : 'Check Out'}</h5>`
            }).open(map, marker);

            markerBounds.extend(coordinate);
          }
        })
        map.fitBounds(markerBounds);
      }
      window.initMap = initMap;
      """ + bypass() + """
    </script>
  </body>
</html>
    """;
}