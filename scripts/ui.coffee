class UI
  constructor: (google) ->
    @google = google
    @inspections = new Inspections()
    @url = "https://data.cityofchicago.org/resource/4ijn-s7e5.json"
    @restaurantName = null
    @mark = null

  # findDirtyRestaurants: ->
  #   $.getJSON(@url).done @getOnlyRestaurantsHasViolations

  # getOnlyRestaurantsHasViolations: (data) =>
  #   i = 0
  #   googleMap = new GoogleMap(@google)
  #   while i < data.length
  #     unless _.isUndefined(data[i].violations)
  #       $.getJSON(@url, {"dba_name": data[i].dba_name}).done (data) =>
  #         mark = googleMap.markLocation data[0].latitude, data[0].longitude
  #         googleMap.openInfoWindow mark, data[0], @howManyViolations(data)
  #     i++

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
      @setTitle(data)
      googleMap = new GoogleMap(@google)
      $("#map-canvas").off "click"
      googleMap.map.setCenter(googleMap.getLocation(data[0].latitude, data[0].longitude))
      googleMap.markLocation data[0].latitude, data[0].longitude
      @setTableHead()
      while i < data.length
        @setTableBody(data, i)
        i++

  searchingRestaurant: ->
    $("form").submit (e) =>
      @searchWords()
      @resetSearchResult()
      @searchResult()
      e.preventDefault()

  resetSearchResult: ->
    $(".form-control").val("")
    $(".page-header, small, tr, th, td").remove()
    $(".bg-danger, br").remove()

  setMapCSS: ->
    $("#map-canvas").css "height": "37%", "width": "50%"

  noResultMessage: ->
    $(".result").before "<br><br><p class='bg-danger'>No results for &nbsp'#{@restaurantName}'</p>"

  setTitle: (data) ->
    $(".title").append """<h1 class = 'page-header'>#{@restaurantName}
                         <small>&nbsp&nbsp(#{data[0].address}, Chicago)</small>"""

  setTableHead: ->
    $("thead").append """<tr>
                            <th>#</th>
                            <th>Inspection Type</th>
                            <th>Inspection Date</th>
                            <th>Risk</th>
                            <th>Results</th>
                            <th>Violations</th>
                        </tr>"""

  setTableBody: (data, i) ->
    date = @resetDate(data, i)
    violations = @replaceString(data, i)
    $("tbody").append """<tr><td>#{i+1}</td><td>#{data[i].inspection_type}</td><td>
                      #{date}</td><td>#{data[i].risk}</td><td>#{data[i].results}
                      </td><td>#{violations}</td></tr>"""

  replaceString: (data, i) ->
    data[i].violations.replace(/\s*\|\s*/gi, '<br>')

  resetDate: (data, i) ->
    data[i].inspection_date.replace('T00:00:00', '')

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

  goBackHome: ->
    $(".navbar-brand").click =>
      $("#map-canvas").css "height": "70%", "width": "100%"
      @resetSearchResult()
      @findDirtyRestaurants()

  mainPage: ->
    @goBackHome()
    # @findDirtyRestaurants()
    @searchingRestaurant()

window.UI = UI
