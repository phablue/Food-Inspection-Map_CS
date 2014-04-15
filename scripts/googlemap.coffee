class GoogleMap
  constructor: (google) ->
    @google = google
    @ui = new UI(google)
    @mapConfig =
      center: new google.maps.LatLng 41.8819, -87.6278
      zoom: 14
    @map = new google.maps.Map $("#map-canvas")[0], @mapConfig
    $('#map-canvas').on 'click', '.detail', (e) =>
      @ui.restaurantName = $(e.target).data('id')
      @ui.searchResult()

  getLocation: (latitude, longitude) ->
    new @google.maps.LatLng  latitude, longitude

  markLocation: (latitude, longitude) ->
    marker = new @google.maps.Marker
      position: @getLocation(latitude, longitude),
      map: @map

  openInfoWindow: (mark, data, violations)->
    @google.maps.event.addListener mark, 'click', =>
      infowindow = @infoWindow(data, violations)
      infowindow.open(@map, mark)

  infoWindow: (data, violations) ->
    infowindow = new @google.maps.InfoWindow
      content: '<div class="'+data.license_+'">'+
                  '<div id="content">'+
                    '<div id="siteNotice">'+'</div>'+'<h1>'+data.dba_name+'</h1>'+
                    '<div id="bodyContent">'+
                      '<p class="lead"><b>Address : &nbsp</b>'+data.address+', CHICAGO</p>'+
                      '<p class="lead"><b>Total violations : &nbsp</b>'+violations+'</p>'+
                      '<p class="lead"><b>Detail violations : &nbsp</b><a data-id="' + data.dba_name + '" class = "detail">Go Detail</a></p>'+
                    '</div>'+
                  '</div>'+
                '</div>'

window.GoogleMap = GoogleMap
