class GoogleMap
  constructor: ->
    @googleMapAPI = "http://maps.googleapis.com/maps/api/js?key=AIzaSyDbO8RZqVj4nFqlBQbDVR4unkIaoxNjYcE&sensor=false"

  getGoogleData: ->
    $.getJSON(@googleMapAPI).done @showGoogleMap

  setGoogleMap: (google) ->
    mapProp =
      center: new google.maps.LatLng(41.8819, -87.6278)
      zoom: 11
      mapTypeId: google.maps.MapTypeId.ROADMAP

    map = new google.maps.Map($("#map-canvas"), mapProp)

  showGoogleMap: (data) =>
    console.log(data)
    (data.google).maps.event.addDomListener(window, 'load', @setGoogleMap(data.google))

window.GoogleMap = GoogleMap
