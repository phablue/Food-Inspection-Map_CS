class GoogleMap
  setGoogleMap: (google) ->
    mapProp =
      center: new google.maps.LatLng(41.8819, -87.6278)
      zoom: 11
      mapTypeId: google.maps.MapTypeId.ROADMAP

    map = new google.maps.Map($("#map-canvas")[0], mapProp)

window.GoogleMap = GoogleMap
