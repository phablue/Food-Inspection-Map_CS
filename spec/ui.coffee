describe "Test UI", ->
  fakeServer = null
  ui = null
  googlemap = null

  beforeEach ->
    @google = 
      maps:
        LatLng: ->
        Map: ->
          setCenter: ->
        Marker: ->
        InfoWindow: ->
        event: ->
          addListener: ->

    setFixtures ('<a class="navbar-brand" data-id="home">Food Inspection Map in Chicago</a>
                  <form>
                    <input type="text" class="form-control" data-id="searchWord" placeholder="Search...">
                  </form>
                  <div id="map-canvas data-id="googlaMap"></div>
                  <div class="result" data-id="result"><div class="title" data-id="title"></div>
                    <table>
                      <thead></thead>
                      <tbody></tbody>
                    </table>
                  </div>')

    fakeServer = sinon.fakeServer.create()
    ui = new UI(@google)
    googlemap = new GoogleMap(@google)

  afterEach ->
    fakeServer.restore()

  respondToRestaurantsUI = (url, data) ->
    fakeServer.respondWith('GET', url, [200, {'content-type': 'application/json'}, JSON.stringify(data)])

  respondNoDataToRestaurantsUI = (url) ->
    fakeServer.respondWith('GET', url, [204, {'content-type': 'application/json'}, JSON.stringify([])])

  describe "Test searchWords function", ->
    it "Changes restaurantName value", ->
      $("[data-id='searchWord']").val "EpicBurger"

      result = ui.searchWords()
      expect(result).toBe "EpicBurger"

  describe "Test searchResult function", ->
    data = null
    url = null

    getRequestsOfSearchResultFunc = ->
      ui.searchResult()
      fakeServer.respond()

    beforeEach ->
      ui.restaurantName = "Domino pizza"
      data = [{license_: "123456", dba_name: "Domino pizza", address: "DownTown", violations: "dirty", inspection_date: "2014-10-05T00:00:00"}]

      respondToRestaurantsUI(ui.inspections.url(), data)

    it "Call setMapCSS function if data's dba_name match to restaurantName", ->
      setMapCSS = spyOn(ui, "setMapCSS")

      getRequestsOfSearchResultFunc()

      expect(setMapCSS).toHaveBeenCalled

    it "Call markLocation function if data's dba_name match to restaurantName", ->
      markLocation = spyOn(googlemap, "markLocation")

      getRequestsOfSearchResultFunc()

      expect(markLocation).toHaveBeenCalled

    it "Makes <h1> tag if data has violations", ->
      expect($("[data-id='restaturantName']")).not.toExist

      getRequestsOfSearchResultFunc()

      expect($("[data-id='restaturantName']")).toExist

    it "Text in <h1> is restaurantName if data has violations", ->
      expect($("[data-id='restaturantName']")).not.toExist

      getRequestsOfSearchResultFunc()

      expect($("[data-id='restaturantName']")).toContainText "Domino pizza"

    it "Makes <small> tag if data has violations", ->
      expect($("[data-id='restaturantAddress']")).not.toExist

      getRequestsOfSearchResultFunc()

      expect($("[data-id='restaturantAddress']")).toExist

    it "Text in <small> is address if data has violations", ->
      expect($("[data-id='restaturantAddress']")).not.toExist

      getRequestsOfSearchResultFunc()

      expect($("[data-id='restaturantAddress']")).toContainText "DownTown"

    it 'Makes <tr><td> in <tbody> if data has violations', ->
      expect($("[data-id='tableBody']")).not.toExist
      expect($("[data-id='tableBody'] td")).not.toExist

      getRequestsOfSearchResultFunc()

      expect($("[data-id='tableBody']")).toExist
      expect($("[data-id='tableBody'] td")).toExist

    it '<td> <td> in <tbody> has data values if data has violations', ->
      expect($("[data-id='tableBody'] td")).not.toExist

      getRequestsOfSearchResultFunc()

      expect($("[data-id='tableBody'] td")).toContainText "dirty"
      expect($("[data-id='tableBody'] td")).toContainText "2014-10-05"

    it "Call noResultMessage function if data's dba_name doesnt match to restaurantName", ->
      respondNoDataToRestaurantsUI(ui.inspections.url())

      noResultMessage = spyOn(ui, "noResultMessage")

      getRequestsOfSearchResultFunc()

      expect(noResultMessage).toHaveBeenCalled

    it 'Makes <p> tag for warnning message if data empty', ->
      respondNoDataToRestaurantsUI(ui.inspections.url())

      expect($("[data-id='noResultMessage']")).not.toExist

      getRequestsOfSearchResultFunc()

      expect($("[data-id='noResultMessage']")).toExist

    it 'Text in <p> has a warnning message if data empty', ->
      respondNoDataToRestaurantsUI(ui.inspections.url())

      expect($("[data-id='noResultMessage']")).not.toExist

      getRequestsOfSearchResultFunc()

      expect($("[data-id='noResultMessage']")).toContainText "No results for"

  describe "Test searchingRestaurant function", ->
    data = null

    beforeEach ->
      data = [{dba_name: "dimsum", address: "The Loop", violations: "dirty", inspection_date: "2014-10-05T00:00:00", risk: "high", inspection_type: "risk", results: "failed"}]

    it "Show title after submit search words", ->
      $("[data-id='searchWord']").val "dimsum"

      expect($("[data-id='restaturantName']")).not.toExist
      expect($("[data-id='restaturantAddress']")).not.toExist

      ui.searchingRestaurant()
      $("form").trigger("submit")

      respondToRestaurantsUI(ui.inspections.url(), data)
      fakeServer.respond()

      expect($("[data-id='restaturantName']")).toContainText "dimsum"
      expect($("[data-id='restaturantAddress']")).toContainText "The Loop"

    it "Show data on table after submit search words", ->
      $("[data-id='searchWord']").val "dimsum"

      expect($("[data-id='tableHead'] th")).not.toExist
      expect($("[data-id='tableBody'] td")).not.toExist

      ui.searchingRestaurant()
      $("form").trigger("submit")

      respondToRestaurantsUI(ui.inspections.url(), data)
      fakeServer.respond()

      expect($("[data-id='tableHead'] th")).toContainText "Violations"
      expect($("[data-id='tableBody'] td")).toContainText "dirty"

    it "show warnning message if search word is not in data, after search", ->
      $("[data-id='searchWord']").val "pizza"

      expect($("[data-id='noResultMessage']")).not.toExist

      ui.searchingRestaurant()
      $("form").trigger("submit")

      respondNoDataToRestaurantsUI(ui.inspections.url())
      fakeServer.respond()

      expect($("[data-id='noResultMessage']")).toContainText "No results for"

  describe "Test resetSearchWords function", ->
    it "reset textbox value", ->
      $("[data-id='searchWord']").val "dimsum"

      expect($(".form-control")).toHaveValue "dimsum"

      ui.resetSearchWords()

      expect($(".form-control")).toBeEmpty

  describe "Test resetSearch function", ->
    it "Reset detailed search result", ->
      $("tbody").append "<tr data-id='tableBody'><td>hi</td></tr>"

      expect($("[data-id='tableBody'] td")).toExist
      expect($("[data-id='tableBody'] td")).toHaveText "hi"

      ui.resetSearch()

      expect($("[data-id='tableBody'] td")).not.toExist
      expect($("[data-id='tableBody'] td")).not.toHaveText "hi"

    it "Reset no search result message", ->
      $(".title").prepend "<p class='bg-danger' data-id='noResultMessage'>danger</p>"

      expect($("[data-id='noResultMessage']")).toExist

      ui.resetSearch()

      expect($("[data-id='noResultMessage']")).not.toExist

    it "Reset search restaurant name in title", ->
      $(".title").append "<h1 class='page-header' data-id='restaturantName'>Pizza House</h1>"

      expect($("[data-id='restaturantName']")).toExist
      expect($("[data-id='restaturantName']")).toContainText "Pizza House"

      ui.resetSearch()

      expect($("[data-id='restaturantName']")).not.toExist

    it "Reset search restaurant address in title", ->
      $(".title").append "<small data-id='restaturantAddress'>Loop</small>"

      expect($("[data-id='restaturantAddress']")).toExist
      expect($("[data-id='restaturantAddress']")).toContainText "Loop"

      ui.resetSearch()

      expect($("small[data-id='restaturantAddress']")).not.toExist

    it "Reset search results list", ->
      $(".title").before """<li data-id='resultsList'><h3 data-id='123'>Subway
                            <small data-id='123'> (The Loop)</small></h3></li>"""

      expect($("[data-id='resultsList']")).toExist

      ui.resetSearch()

      expect($("[data-id='resultsList']")).not.toExist

  describe "Test goBackHome function", ->
    it "call functions after click", ->
      resetSearch = spyOn(ui, "resetSearch")
      reDisplayRestaurantsOnGoogleMap = spyOn(ui, "reDisplayRestaurantsOnGoogleMap")

      ui.goBackHome()
      $(".navbar-brand").click()

      expect(resetSearch).toHaveBeenCalled
      expect(reDisplayRestaurantsOnGoogleMap).toHaveBeenCalled

  describe "Test replaceViolations and resetDate functions", ->
    dataModel = null

    beforeEach ->
      dataModel = new Backbone.Model
        dba_name: "Domino pizza"
        address: "DownTown"
        violations: "dirty | smell"
        inspection_date: "2014-04-16T00:00:00"

    it "'|' change to <br> if data has '|'", ->
      expect(dataModel.get("violations")).toBe("dirty | smell")

      result = ui.replaceViolations(dataModel)

      expect(result).toEqual("dirty<br>smell")

    it "Data format is year-month-date", ->
      expect(dataModel.get("inspection_date")).toBe("2014-04-16T00:00:00")

      result = ui.resetDate(dataModel)

      expect(result).toEqual("2014-04-16")
