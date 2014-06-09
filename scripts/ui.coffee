class UI
  constructor: (google) ->
    @google = google
    @inspections = new Inspections({google: google, ui: this})
    @restaurantID = null
    @mark = null

  getInspectionsDataOnGoogleMap: ->
    @inspections.fetch
      success: =>
        @inspections.restaurantsViolationsOnGoogleMap(@inspections.licenseIDsOfRestaurantsViolations())

  searchWords: ->
    $(".form-control").val()

  searchResult: ->
    @inspections.fetch
      success: =>
        @showResult(@inspections.licenseIDsOfRestaurantsViolations())

  showResult: (data) ->
    @resetSearchResult()
    if _.isEmpty(data)
      return @noResultMessage()
    else if data.length == 1
      return @showDetailOfResult(@inspections.restaurantsFilterBy2014Year())
    @resultMessage(data.length)
    googleMap = new GoogleMap(@google)
    _.each(data, (d) =>
      restaturant = @inspections.restaurantHasViolationsByLicenseID(d)
      @inspections.settingForGoogleMap(googleMap, restaturant)
      @setResultsList(restaturant[0]))
    @resultsList()

  resultsList: ->
    $("h3").click =>
      @restaurantID = $(event.target).data('id')
      @searchResult()

  showDetailOfResult: (data) ->
    @setMapCSS("37%", "50%")
    @setTitle(data)
    @showMarkOnGoogleMap(data)
    @setTableHead()
    _.each(data, (d) => @setTableBody(d))

  searchingRestaurant: ->
    $("form").submit (e) =>
      @searchWords()
      @searchResult()
      e.preventDefault()

  goBackHome: ->
    $(".navbar-brand").click =>
      @setMapCSS("70%", "100%")
      @resetSearchResult()
      @getInspectionsDataOnGoogleMap()

  mainPage: ->
    @goBackHome()
    @getInspectionsDataOnGoogleMap()
    @searchingRestaurant()

  showMarkOnGoogleMap: (data) ->
    googleMap = new GoogleMap(@google)
    $("#map-canvas").off "click"
    googleMap.map.setCenter(googleMap.getLocation(data[0].get("latitude"), data[0].get("longitude")))
    googleMap.markLocation data[0].get("latitude"), data[0].get("longitude")

  resetSearchWords: ->
    $(".form-control").val("")

  resetSearch: ->
    $("li, .page-header, small, tr, th, td, .bs-callout-warning, .bg-danger, br").remove()
    @setMapCSS("70%", "100%")
    @restaurantID = null

  noResultMessage: ->
    @setMapCSS("0%", "0%")
    $(".result").before "<br><br><p class='bg-danger'>No results for &nbsp'#{@restaurantName}'</p>"

  resultMessage: (totalResultQty) ->
    $(".result").before "<div class='bs-callout bs-callout-warning'><h3>About #{totalResultQty} results<h3> </div>"

  setResultsList: (data) ->
    $(".title").before "<li><h3 data-id='#{data.get('license_')}'>#{data.get('dba_name').toUpperCase()} <small data-id='#{data.get('license_')}'> (#{data.get('address')})</small></h3></li>"

  setMapCSS: (height, width) ->
    $("#map-canvas").css "height": "#{height}", "width": "#{width}"

  setTitle: (data) ->
    $(".title").append """<h1 class = 'page-header'>#{data[0].get("dba_name")}
                         <small>&nbsp&nbsp(#{data[0].get("address")}, Chicago)</small>"""

  setTableHead: ->
    $("thead").append """<tr>
                            <th>Inspection Date</th>
                            <th>Inspection Type</th>
                            <th>Risk</th>
                            <th>Results</th>
                            <th>Violations</th>
                        </tr>"""

  setTableBody: (data) ->
    date = @resetDate(data)
    violations = @replaceViolations(data)
    $("tbody").append """<tr><td>#{date}</td><td>#{data.get("inspection_type")}</td>
                         <td>#{data.get("risk")}</td><td>#{data.get("results")}
                         </td><td>#{violations}</td></tr>"""

  replaceViolations: (data) ->
    data.get("violations").replace(/\s*\|\s*/gi, '<br>')

  resetDate: (data) ->
    data.get("inspection_date").replace('T00:00:00', '')

window.UI = UI
