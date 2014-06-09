class UI
  constructor: (google) ->
    @google = google
    @inspections = new Inspections({google: google, ui: this})
    @restaurantID = null
    @mark = null

  getInspectionsDataOnGoogleMap: ->
    @displayLoading("40%", "15%")
    @inspections.fetch
      success: =>
        @removeLoading()
        @inspections.restaurantsViolationsOnGoogleMap(@inspections.licenseIDsOfRestaurantsViolations())

  searchWords: ->
    $(".form-control").val()

  searchResult: ->
    @resetSearch()
    @resetGoogleMap()
    @displayLoading("40%", "8%")
    @inspections.fetch
      success: =>
        @removeLoading()
        if !_.isNull(@restaurantID)
          return @showDetailOfResult(@inspections.restaurantsFilterBy2014Year())
        @restaurantID = null
        @showResult(@inspections.licenseIDsOfRestaurantsViolations())

  showResult: (data) ->
    if _.isEmpty(data)
      return @noResultMessage()
    @resetSearchWords()
    if data.length == 1
      return @showDetailOfResult(@inspections.restaurantsFilterBy2014Year())
    @resetSearchWords()
    @resultMessage(data.length)
    googleMap = new GoogleMap(@google)
    _.each(data, (d) =>
      restaturant = @inspections.restaurantsFilterBy(d)
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
      @searchResult()
      e.preventDefault()

  goBackHome: ->
    $(".navbar-brand").click =>
      @resetSearch()
      @restaurantID = null
      @resetGoogleMap()
      @setMapCSS("70%", "100%")
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

  resetGoogleMap: ->
    $("#map-canvas").css "background-color", ""
    $(".gm-style").remove()

  noResultMessage: ->
    @setMapCSS("0%", "0%")
    $(".result").before "<br><br><p class='bg-danger'>No results for &nbsp'#{@searchWords()}'</p>"

  resultMessage: (totalResultQty) ->
    $(".result").before "<div class='bs-callout bs-callout-warning'><h3>About #{totalResultQty} results<h3> </div>"

  setResultsList: (data) ->
    $(".title").before """<li><h3 data-id='#{data.get('license_')}'>#{data.get('dba_name').toUpperCase()}
                            <small data-id='#{data.get('license_')}'> (#{data.get('address')})</small></h3></li>"""

  setMapCSS: (height, width) ->
    $("#map-canvas").css "height": "#{height}", "width": "#{width}"

  setTitle: (data) ->
    $(".title").append """<h1 class='page-header'>#{data[0].get("dba_name")}
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

  displayLoading: (marginL, marginT) ->
    $("#map-canvas").append "<img class='loading' src='./stylesheets/ajax-loader.gif'>"
    @setLoadingCSS(marginL, marginT)

  removeLoading: ->
    $(".loading").remove()

  setLoadingCSS: (marginL, marginT) ->
    $(".loading").css "margin-left": "#{marginL}", "margin-top": "#{marginT}"

window.UI = UI
