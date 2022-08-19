String redrawMaps(double lat, double long) {
  return """
    let iframe = document.getElementById('embed-maps');
    iframe.setAttribute('src', `https://maps.google.com/maps?q=${lat},${long}&z=15&output=embed`)
    // el.attributes.src = `https://maps.google.com/maps?q=${lat},${long}&z=10&output=embed`
  """;
}