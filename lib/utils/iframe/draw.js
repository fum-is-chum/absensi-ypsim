document.addEventListener("DOMContentLoaded", (event) => { 

  x1 = 3.5941018719816338;
  y1 = 98.66775177746435;

  x2 = 3.5946501693153463;
  y2 = 98.67448949355177;

  zoom = 15
  const meterPerPx = (lat, zoom) => {
    return 156543.03392 * Math.cos(lat * Math.PI / 180) / Math.pow(2, zoom)
  }
  
  // return [x diff, y diff]
  const distanceMeter = (x1, y1, x2, y2) => {
    function toRadians(value) {
      return value * Math.PI / 180
    }
  
    var R = 6371.0710
    var rlat1 = toRadians(x1) // Convert degrees to radians
    var rlat2 = toRadians(x2) // Convert degrees to radians
    var difflat = rlat2 - rlat1 // Radian difference (latitudes)
    var difflon = toRadians(y2 - y1) // Radian difference (longitudes)
    return 2 * R * Math.asin(Math.sqrt(Math.sin(difflat / 2) * Math.sin(difflat / 2) + Math.cos(rlat1) * Math.cos(rlat2) * Math.sin(difflon / 2) * Math.sin(difflon / 2))) * 1000
  }; 

  const newCanvas = () => {
    let canvas = document.createElement('canvas');
    canvas.style.position = 'absolute';
    const body = document.body;
    body.insertAdjacentElement('afterbegin', canvas);
    return canvas;
  }

  // diameter in meter
  const newPoint = (x2, y2, diameter) => {
    let canvas = newCanvas();
  
    const mPerPx = meterPerPx(x1, zoom);
    const jarak = distanceMeter(x1,y1,x2,y2)
    const R = Math.ceil((diameter / 2) / mPerPx); 
    const S  = (R * 2) + 5;

    canvas.setAttribute('width', S);
    canvas.setAttribute('height', S);

    const dy = ((x1 - x2) * 110132) / mPerPx;
    const dx = (Math.sqrt(Math.pow(jarak, 2) - Math.pow(dy, 2))) / mPerPx;
    
    console.log(jarak, dx, dy);

    canvas.style.left = `calc(50% + ${dx}px - ${R}px)`;
    canvas.style.top = `calc(50% + ${dy}px - ${R}px)`;

    if (canvas.getContext) {
      var ctx = canvas.getContext('2d'); 
      var X = canvas.width / 2;
      var Y = canvas.height / 2;
  
      ctx.beginPath();
      ctx.arc(X, Y, R, 0, 2 * Math.PI, false);
      ctx.lineWidth = 1.5;
      ctx.strokeStyle = '#FF0000';
      ctx.fillStyle = '#00000022'
      ctx.stroke();
      ctx.fill();
    }
  }
  newPoint(x1, y1, 1000);
  newPoint(x1, y1, 1);
});