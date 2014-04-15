class UI
  constructor: (google) ->
    @google = google
    @url = "https://data.cityofchicago.org/resource/4ijn-s7e5.json"
    @restaurantName = null

  findDirtyRestaurants: ->
    $.getJSON(@url).done @getOnlyRestaurantsHasViolations

  getOnlyRestaurantsHasViolations: (data) =>
    i = 0
    googleMap = new GoogleMap(@google)
    while i < data.length
      unless _.isUndefined(data[i].violations)
        mark = googleMap.markLocation data[i].latitude, data[i].longitude
        googleMap.openInfoWindow mark, data[i]
      i++
    #how to make link?

  searchWords: ->
    @restaurantName = $(".form-control").val()

  searchResult: ->
    $.getJSON(@url, {"dba_name": @restaurantName}).done @showResult

  showResult: (data) =>
    if _.isEmpty(data)
      @noResultMessage()
    else if !@checkHasViolations(data)
      i = 0
      @setMapCSS()
      @showElement ".result"
      @setPageHeader(data)
      googleMap = new GoogleMap(@google)
      googleMap.mapConfig.center = new @google.maps.LatLng data[0].latitude, data[0].longitude
      googleMap.markLocation data[0].latitude, data[0].longitude
      while i < data.length
        @setTableBody(data, i)
        i++
        # how to json data edit? '|' replace to "\n"
        # pass getjson  searchwords include name

  searchingRestaurant: ->
    @findDirtyRestaurants()
    @hideElement ".result"
    $("form").submit =>
      @resetSearchResult()
      @searchWords()
      @searchResult()
      event.preventDefault()

  resetSearchResult: ->
    $(".title, tbody").empty()
    $(".bg-danger, br").remove();
    $(".title").html '<h1 class = "page-header"><small></small></h1>'

  hideElement: (element) ->
    $(element).hide()

  showElement: (element) ->
    $(element).show()

  setMapCSS: ->
    $("#map-canvas").css "height": "37%", "width": "50%"

  noResultMessage: ->
    $(".result").before '<br><br><p class="bg-danger">No results for &nbsp"'+@restaurantName+'"</p>'

  setPageHeader: (data) ->
    $(".page-header").text @restaurantName
    $(".page-header").append "<small>&nbsp&nbsp("+data[0].address+", Chicago)</small>"

  setTableBody: (data, i) ->
    $("tbody").append "<tr><td>"+(i+1)+"</td><td>"+data[i].inspection_type+"</td><td>" +
                      data[i].inspection_date+"</td><td>"+data[i].risk+"</td><td>"+data[i].results+
                      "</td><td>"+data[i].violations+"</td></tr>"

  checkHasViolations: (data) ->
    true if _.isNull(@howManyViolations(data))
    false

  howManyViolations: (data) ->
    violations = 0
    i = 0
    while i < data.length
      if !_.isUndefined(data[i].violations)
        violations++
      i++
    violations

window.UI = UI
