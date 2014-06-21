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
        @inspections.restaurantsOnGoogleMapBy()

  searchWords: ->
    $("[data-id='searchWord']").val()

  searchResult: ->
    @resetSearch()
    @resetGoogleMap()
    @displayLoading("40%", "8%")
    @inspections.fetch
      success: =>
        @removeLoading()
        @restaurantID = null
        if !_.isNull(@restaurantID)
          return @showDetailOfResult(@inspections.models)
        restaturants = @inspections.filterByKeyWordsFor()
        restaturantIDs = @inspections.licenseIDsOf(new Backbone.Collection(restaturants))
        @showResult(restaturants, restaturantIDs)

  showResult: (restaturants, restaturantIDs) ->
    if _.isEmpty(restaturantIDs)
      return @noResultMessage()
    @resetSearchWords()
    if restaturantIDs.length == 1
      return @showDetailOfResult(@inspections.models)
    @resultMessage(restaturantIDs.length)
    googleMap = new GoogleMap(@google)
    _.each(restaturantIDs, (restaturantID) =>
      restaturant = @inspections.restaurantsFilterBy(restaturants, restaturantID)
      @inspections.settingForGoogleMap(googleMap, restaturant)
      @setResultsList(restaturant[0]))
    @resultsList()

  resultsList: ->
    $("[data-id='resultsList']").click =>
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
    $("[data-id='home']").click =>
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
    $("[data-id='googlaMap']").off "click"
    googleMap.map.setCenter(googleMap.getLocation(data[0].get("latitude"), data[0].get("longitude")))
    googleMap.markLocation data[0].get("latitude"), data[0].get("longitude")

  resetSearchWords: ->
    $("[data-id='searchWord']").val("")

  resetSearch: ->
    @resetResultsList()
    @resetSearchTitle()
    @resetNoResultMessage()
    @resetResultMessage()
    @resetResultTable()
    @setMapCSS("70%", "100%")

  resetResultsList: ->
    @remove("[data-id='resultsList']")

  resetSearchTitle: ->
    @remove("[data-id='restaturantName']")
    @remove("[data-id='restaturantAddress']")

  resetNoResultMessage: ->
    @remove("[data-id='noResultMessage']")

  resetResultMessage: ->
    @remove("[data-id='resultMessage']")

  resetGoogleMap: ->
    $("[data-id='googlaMap']").css "background-color", ""
    @remove(".gm-style")

  resetResultTable: ->
    @remove("[data-id='tableHead']")
    @remove("[data-id='tableBody']")

  remove: (elements) ->
    $(elements).remove()

  noResultMessage: ->
    @setMapCSS("0%", "0%")
    $("[data-id='result']").before "<br><br><p class='bg-danger' data-id='noResultMessage'>No results for &nbsp'#{@searchWords()}'</p>"

  resultMessage: (totalResultQty) ->
    $("[data-id='result']").before "<div class='bs-callout bs-callout-warning' data-id='resultMessage'><h3>About #{totalResultQty} results<h3> </div>"

  setResultsList: (data) ->
    $("[data-id='title']").before """<li data-id='resultsList'><h3 data-id='#{data.get('license_')}'>#{data.get('dba_name').toUpperCase()}
                            <small data-id='#{data.get('license_')}'> (#{data.get('address')})</small></h3></li>"""

  setMapCSS: (height, width) ->
    $("[data-id='googlaMap']").css "height": "#{height}", "width": "#{width}"

  setTitle: (data) ->
    $("[data-id='title']").append """<h1 class='page-header' data-id='restaturantName'>#{data[0].get("dba_name")}
                         <small data-id='restaturantAddress'>&nbsp&nbsp(#{data[0].get("address")}, Chicago)</small>"""

  setTableHead: ->
    $("thead").append """<tr data-id='tableHead'>
                            <th>Inspection Date</th>
                            <th>Inspection Type</th>
                            <th>Risk</th>
                            <th>Results</th>
                            <th>Violations</th>
                        </tr>"""

  setTableBody: (data) ->
    date = @resetDate(data)
    violations = @replaceViolations(data)
    $("tbody").append """<tr data-id='tableBody'><td>#{date}</td><td>#{data.get("inspection_type")}</td>
                         <td>#{data.get("risk")}</td><td>#{data.get("results")}
                         </td><td>#{violations}</td></tr>"""

  replaceViolations: (data) ->
    data.get("violations").replace(/\s*\|\s*/gi, '<br>')

  resetDate: (data) ->
    data.get("inspection_date").replace('T00:00:00', '')

  displayLoading: (marginL, marginT) ->
    $("[data-id='googlaMap']").append "<img data-id='loading' src='./stylesheets/ajax-loader.gif'>"
    @setLoadingCSS(marginL, marginT)

  removeLoading: ->
    $("[data-id='loading']").remove()

  setLoadingCSS: (marginL, marginT) ->
    $("[data-id='loading']").css "margin-left": "#{marginL}", "margin-top": "#{marginT}"

window.UI = UI
