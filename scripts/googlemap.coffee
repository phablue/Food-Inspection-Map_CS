class GoogleMap
  constructor: (google) ->
    @google = google
    @ui = new UI(google)
    @infoWindows = []
    @currentMark = null
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

  openInfoWindow: (mark, data, violations) ->
    infowindow = @infoWindow(data, violations)
    @infoWindows[infowindow.id] = infowindow
    @google.maps.event.addListener mark, 'click', =>
      @checkCurrentWindow(infowindow)
      infowindow.open(@map, mark)

  checkCurrentWindow: (infowindow)->
    if @currentMark == null
      @currentMark = infowindow.id
    else if infowindow.id != @currentMark
      @infoWindows[@currentMark].close()
      @currentMark = infowindow.id

  infoWindow: (data, violations) ->
    infowindow = new @google.maps.InfoWindow
      id: data.license_
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
