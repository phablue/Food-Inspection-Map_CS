class GoogleMap
  constructor: (google)->
    @google = google
    mapConfig =
      center: new google.maps.LatLng 41.8819, -87.6278
      zoom: 11
      mapTypeId: google.maps.MapTypeId.ROADMAP
    @map = new google.maps.Map $("#map-canvas")[0], mapConfig

  getLocation: (latitude, longitude) ->
    new @google.maps.LatLng  latitude, longitude

  markLocation: ->
    marker = new @google.maps.Marker
      position: @getLocation(),
      map: @map

window.GoogleMap = GoogleMap
