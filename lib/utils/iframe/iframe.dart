import 'package:geolocator/geolocator.dart';

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
  return r"""
    var target=document.head,observer=new MutationObserver(function(e){for(var t=0;e[t];++t)if(e[t].addedNodes.length>0)try{if("SCRIPT"==e[t].addedNodes[0].nodeName&&e[t].addedNodes[0].src.match(/\/AuthenticationService.Authenticate?/g)||e[t].addedNodes[0].src.match(/\/QuotaService.RecordEvent?/g)){var a=e[t].addedNodes[0].src.match(/[?&]callback=.*[&$]/g);if(a){var d=(a="&"==a[0][a[0].length-1]?a[0].substring(10,a[0].length-1):a[0].substring(10)).split("."),r=d[0],c=d[1];window[r][c]=null,window[r]={}}}}catch(s){}}),config={attributes:!0,childList:!0,characterData:!0};observer.observe(target,config);
    """;
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

      radius = ${target['radius']}
      document.dispatchEvent(new Event(POSITION_UPDATE));
    } catch (e) {
      // alert(e);
    }
  """;
}

String homeMap(Position? pos1, double lat2, double lng2, int radius) {
  return map() +
      """
    <script>
      const POSITION_UPDATE = 'position-update';
      // Initialize and add the map
      const coordinates = [
        { lat: ${pos1?.latitude ?? null}, lng: ${pos1?.longitude ?? null} },
        { lat: $lat2, lng: $lng2 }
      ];
      
      let radius = $radius;
      function initMap() {
        const map = new google.maps.Map(document.getElementById("map"), {
          zoom: 15,
        });

        const markerBounds = new google.maps.LatLngBounds();
        const markers = []

        coordinates.forEach((coordinate, idx) => {
          if(coordinate.lat) {
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
          }
        })

        const targetRadius = new google.maps.Circle({
          map: map,
          radius: radius,
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
          try {
            const newMarkerbounds = new google.maps.LatLngBounds();
            coordinates.forEach((coordinate, idx) => {
              markers[idx].setPosition(coordinate);
              newMarkerbounds.extend(coordinate);
            })

            targetRadius.setRadius(radius);
            targetRadius.setCenter(coordinates[1]);
            map.fitBounds(newMarkerbounds);
          } catch (e) {
            console.error(e)
          }
        })
      }
      window.initMap = initMap;
      """ +
      bypass() +
      """
    </script>
  </body>
</html>
    """;
}

String detailPresensiMap(
    double? lat1, double? lng1, double? lat2, double? lng2) {
  return map() +
      """
    <script>
     // Initialize and add the map
     function initMap() {
        const coordinates = [
          { lat: $lat1, lng: $lng1 },
          { lat: $lat2, lng: $lng2 }
        ]""" +
      r"""

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
      """ +
      bypass() +
      """
    </script>
  </body>
</html>
    """;
}
