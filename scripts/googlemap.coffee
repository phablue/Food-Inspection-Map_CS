class GoogleMap
  constructor: (google) ->
    @google = google
    mapConfig =
      center: new google.maps.LatLng 41.8819, -87.6278
      zoom: 14
    @map = new google.maps.Map $("#map-canvas")[0], mapConfig

  getLocation: (latitude, longitude) ->
    new @google.maps.LatLng  latitude, longitude

  markLocation: (latitude, longitude) ->
    marker = new @google.maps.Marker
      position: @getLocation(latitude, longitude),
      map: @map

  infoWindow: (contentString) ->
    infowindow = new google.maps.InfoWindow
      content: (contentString)

window.GoogleMap = GoogleMap
