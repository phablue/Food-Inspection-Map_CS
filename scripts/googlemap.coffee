class GoogleMap
  constructor: (google) ->
    @google = google
    @mapConfig =
      center: new google.maps.LatLng 41.8819, -87.6278
      zoom: 14
    @map = new google.maps.Map $("#map-canvas")[0], @mapConfig

  getLocation: (latitude, longitude) ->
    new @google.maps.LatLng  latitude, longitude

  markLocation: (latitude, longitude) ->
    marker = new @google.maps.Marker
      position: @getLocation(latitude, longitude),
      map: @map

  infoWindow: (contentString) ->
    infowindow = new @google.maps.InfoWindow
      content: @contentString

  contentString: (data) ->
    content =  '<div id="content">'+ 
                  '<div id="siteNotice">'+'</div>'+'<h1>'+data.dba_name+'</h1>'+ 
                  '<div id="bodyContent">'+
                    '<p class="lead"><b>Address : &nbsp</b>'+data.address +', CHICAGO</p>'+
                    '<p class="lead"><b>Total violations : &nbsp</b>'+(new UI(@google)).howManyViolations(data)+'</p>'+
                    '<p class="lead"><b>Detail violations : &nbsp</b><a href = "/">Go Detial</a></p>'+
                  '</div>'+
                '</div>'

window.GoogleMap = GoogleMap
