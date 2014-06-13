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

    setFixtures ('<a class="navbar-brand">Food Inspection Map in Chicago</a>
                  <form>
                    <input type="text" class="form-control" placeholder="Search...">
                  </form>
                  <div id="map-canvas"></div>
                  <div class="result"><div class="title"></div>
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
      $(".form-control").val "EpicBurger"

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
      expect($("h1")).not.toExist

      getRequestsOfSearchResultFunc()

      expect($("h1")).toExist

    it "Text in <h1> is restaurantName if data has violations", ->
      expect($("h1")).not.toExist

      getRequestsOfSearchResultFunc()

      expect($("h1")).toContainText "Domino pizza"

    it "Makes <small> tag if data has violations", ->
      expect($("small")).not.toExist

      getRequestsOfSearchResultFunc()

      expect($("small")).toExist

    it "Text in <small> is address if data has violations", ->
      expect($("small")).not.toExist

      getRequestsOfSearchResultFunc()

      expect($("small")).toContainText "DownTown"

    it 'Makes <tr><td> if data has violations', ->
      expect($("tr")).not.toExist
      expect($("td")).not.toExist

      getRequestsOfSearchResultFunc()

      expect($("tr")).toExist
      expect($("td")).toExist

    it '<td> has data values if data has violations', ->
      expect($("td")).not.toExist

      getRequestsOfSearchResultFunc()

      expect($("td")).toContainText "dirty"
      expect($("td")).toContainText "2014-10-05"

    it "Call noResultMessage function if data's dba_name doesnt match to restaurantName", ->
      respondNoDataToRestaurantsUI(ui.inspections.url())

      noResultMessage = spyOn(ui, "noResultMessage")

      getRequestsOfSearchResultFunc()

      expect(noResultMessage).toHaveBeenCalled

    it 'Makes <p> tag for warnning message if data empty', ->
      respondNoDataToRestaurantsUI(ui.inspections.url())

      expect($("p")).not.toExist

      getRequestsOfSearchResultFunc()

      expect($("p")).toExist

    it 'Text in <p> has a warnning message if data empty', ->
      respondNoDataToRestaurantsUI(ui.inspections.url())

      expect($("p")).not.toExist

      getRequestsOfSearchResultFunc()

      expect($("p")).toContainText "No results for"

  describe "Test searchingRestaurant function", ->
    data = null

    beforeEach ->
      data = [{dba_name: "dimsum", address: "The Loop", violations: "dirty", inspection_date: "2014-10-05T00:00:00", risk: "high", inspection_type: "risk", results: "failed"}]

    it "Show title after submit search words", ->
      $(".form-control").val "dimsum"

      expect($("h1")).not.toExist
      expect($("small")).not.toExist

      ui.searchingRestaurant()
      $("form").trigger("submit")

      respondToRestaurantsUI(ui.inspections.url(), data)
      fakeServer.respond()

      expect($("h1")).toContainText "dimsum"
      expect($("small")).toContainText "The Loop"

    it "Show data on table after submit search words", ->
      $(".form-control").val "dimsum"

      expect($("th")).not.toExist
      expect($("td")).not.toExist

      ui.searchingRestaurant()
      $("form").trigger("submit")

      respondToRestaurantsUI(ui.inspections.url(), data)
      fakeServer.respond()

      expect($("th")).toContainText "Violations"
      expect($("td")).toContainText "dirty"

    it "show warnning message if search word is not in data, after search", ->
      $(".form-control").val "pizza"

      expect($("p")).not.toExist

      ui.searchingRestaurant()
      $("form").trigger("submit")

      respondNoDataToRestaurantsUI(ui.inspections.url())
      fakeServer.respond()

      expect($("p")).toContainText "No results for"

  describe "Test resetSearchWords function", ->
    it "reset textbox value", ->
      $(".form-control").val "dimsum"

      expect($(".form-control")).toHaveValue "dimsum"

      ui.resetSearchWords()

      expect($(".form-control")).toBeEmpty

  describe "Test resetSearch function", ->
    it "Reset detailed search result", ->
      $("tbody").append "<tr><td>hi</td></tr>"

      expect($("td")).toExist
      expect($("tbody")).toHaveText "hi"

      ui.resetSearch()

      expect($("td")).not.toExist
      expect($("tbody")).not.toHaveText "hi"

    it "Reset no search result message", ->
      $(".title").prepend '<p class="bg-danger">danger</p>'

      expect($(".bg-danger")).toExist

      ui.resetSearch()

      expect($(".bg-danger")).not.toExist

    it "Reset search title", ->
      $(".title").append "<h1 class = 'page-header'>Pizza House</h1>"

      expect($(".page-header")).toExist

      ui.resetSearch()

      expect($(".page-header")).not.toExist

    it "Reset search results list", ->
      $(".title").before """<li><h3 data-id='123'>Subway
                            <small data-id='123'> (The Loop)</small></h3></li>"""

      expect($(".li")).toExist

      ui.resetSearch()

      expect($(".li")).not.toExist

  describe "Test goBackHome function", ->
    it "call functions after click", ->
      resetSearch = spyOn(ui, "resetSearch")
      getInspectionsDataOnGoogleMap = spyOn(ui, "getInspectionsDataOnGoogleMap")

      ui.goBackHome()
      $(".navbar-brand").click()

      expect(resetSearch).toHaveBeenCalled
      expect(getInspectionsDataOnGoogleMap).toHaveBeenCalled

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
