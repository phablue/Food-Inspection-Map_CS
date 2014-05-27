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

    setFixtures ('<div class = "container">
                  <div id = "map-canvas"></div>
                  <div class = "result">
                    <div class = "title">
                    </div>
                    <div class = "row placeholders">
                      <table class = "table table-striped">
                        <thead>
                        </thead>
                        <tbody>
                        </tbody>
                      </table>
                    </div>
                  </div>')

    fakeServer = sinon.fakeServer.create()
    ui = new UI(@google)
    googlemap = new GoogleMap(@google)

  afterEach ->
    fakeServer.restore()

  respondToRestaurantsUI = (url, data) ->
    fakeServer.respondWith('GET', url, [200, {'content-type': 'application/json'}, JSON.stringify(data)])

  describe "Test searchWords function", ->
    it "Changes restaurantName value", ->
      expect(ui.restaurantName).toBeNull
      $(".form-control").val "EpicBurger"
      ui.searchWords()
      expect(ui.restaurantName).toBe "EpicBurger"

  describe "Test searchResult function", ->
    data = null
    url = null

    beforeEach ->
      ui.restaurantName = "Domino pizza"
      data = [{"dba_name": "Domino pizza", "address": "DownTown", "violations": "dirty", "inspection_date": "2013-10-05T00:00:00"}]
      respondToRestaurantsUI(ui.inspections.url(), data)

    it "Call showResult function if suscess get http request", ->
      showResult = spyOn(ui, "showResult")
      ui.searchResult()
      fakeServer.respond()
      expect(showResult).toHaveBeenCalled

    it "Call setMapCSS function if data's dba_name match to restaurantName", ->
      setMapCSS = spyOn(ui, "setMapCSS")
      ui.searchResult()
      fakeServer.respond()
      expect(setMapCSS).toHaveBeenCalled

    it "Call setTitle function if data's dba_name match to restaurantName", ->
      setTitle = spyOn(ui, "setTitle")
      ui.searchResult()
      fakeServer.respond()
      expect(setTitle).toHaveBeenCalled

    it "Call markLocation function if data's dba_name match to restaurantName", ->
      markLocation = spyOn(googlemap, "markLocation")
      ui.searchResult()
      fakeServer.respond()
      expect(markLocation).toHaveBeenCalled

    it "Call setTableBody function if data's dba_name match to restaurantName", ->
      setTableBody = spyOn(ui, "setTableBody")
      ui.searchResult()
      fakeServer.respond()
      expect(setTableBody).toHaveBeenCalled

    it "Makes <h1> tag if data has violations", ->
      expect($("h1")).not.toExist
      ui.searchResult()
      fakeServer.respond()
      expect($("h1")).toExist

    it "Text in <h1> is restaurantName if data has violations", ->
      expect($("h1")).not.toExist
      ui.searchResult()
      fakeServer.respond()
      expect($("h1")).toContainText "Domino pizza"

    it "Makes <small> tag if data has violations", ->
      expect($("small")).not.toExist
      ui.searchResult()
      fakeServer.respond()
      expect($("small")).toExist

    it "Text in <small> is address if data has violations", ->
      expect($("small")).not.toExist
      ui.searchResult()
      fakeServer.respond()
      expect($("small")).toContainText "DownTown"

    it 'Makes <tr><td> if data has violations', ->
      expect($("tr")).not.toExist
      expect($("td")).not.toExist
      ui.searchResult()
      fakeServer.respond()
      expect($("tr")).toExist
      expect($("td")).toExist

    it '<td> has data values if data has violations', ->
      expect($("td")).not.toExist
      ui.searchResult()
      fakeServer.respond()
      expect($("td")).toContainText "dirty"
      expect($("td")).toContainText "2013-10-05"

    it "Call noResultMessage function if data's dba_name doesnt match to restaurantName", ->
      fakeServer.respondWith('GET', url, [204, {'content-type': 'application/json'}, JSON.stringify([])])
      noResultMessage = spyOn(ui, "noResultMessage")
      ui.searchResult()
      fakeServer.respond()
      expect(noResultMessage).toHaveBeenCalled

    it 'Makes <p> tag for warnning message if data empty', ->
      fakeServer.respondWith('GET', url, [204, {'content-type': 'application/json'}, JSON.stringify([])])
      expect($("p")).not.toExist
      ui.searchResult()
      fakeServer.respond()
      expect($("p")).toExist

    it 'Text in <p> has a warnning message if data empty', ->
      fakeServer.respondWith('GET', url, [204, {'content-type': 'application/json'}, JSON.stringify([])])
      expect($("p")).not.toExist
      ui.searchResult()
      fakeServer.respond()
      expect($("p")).toContainText "No results for"      

  describe "Test showResult function", ->
    data = null

    beforeEach ->
      ui.restaurantName = "Domino pizza"
      dataModel = new Backbone.Model
        dba_name: "Domino pizza"
        address: "DownTown"
        violations: "dirty"
        inspection_date: "2013-10-05T00:00:00"
      dataCollection = new Backbone.Collection([dataModel])
      data = dataCollection.models

    it "Makes <h1> tag if data has violations", ->
      expect($("h1")).not.toExist
      ui.showResult(data)
      expect($("h1")).toExist

    it "Text in <h1> is restaurantName if data has violations", ->
      expect($("h1")).not.toExist
      ui.showResult(data)
      expect($("h1")).toContainText "Domino pizza"

    it "Makes <small> tag if data has violations", ->
      expect($("small")).not.toExist
      ui.showResult(data)
      expect($("small")).toExist

    it "Text in <small> is address if data has violations", ->
      expect($("small")).not.toExist
      ui.showResult(data)
      expect($("small")).toContainText "DownTown"

    it 'Makes <p> tag for warnning message if data empty', ->
      data = []
      expect($("p")).not.toExist
      ui.showResult(data)
      expect($("p")).toExist

    it 'Text in <p> has a warnning message if data empty', ->
      data = []
      expect($("p")).not.toExist
      ui.showResult(data)
      expect($("p")).toContainText "No results for"

    it 'Makes <tr><td> if data has violations', ->
      expect($("tr")).not.toExist
      expect($("td")).not.toExist
      ui.showResult(data)
      expect($("tr")).toExist
      expect($("td")).toExist

    it '<td> has data values if data has violations', ->
      expect($("td")).not.toExist
      ui.showResult(data)
      expect($("td")).toContainText "dirty"
      expect($("td")).toContainText "2013-10-05"

  describe "Test searchingRestaurant function", ->
    data = null
    e = null
    url = null

    beforeEach ->
      e = $.Event("submit")
      data = [{"dba_name": "dimsum", "address": "The Loop", "violations": "dirty", "inspection_date": "2013-10-05T00:00:00"}]

    it "ui.restaurantName value changed to search words after submit search words", ->
      respondToRestaurantsUI(ui.inspections.url(), data)
      ui.searchingRestaurant()
      $(".form-control").val "dimsum"
      $(".form-control").trigger(e)
      fakeServer.respond()
      expect(ui.restaurantName).toBe "dimsum"

    it "Show title after submit search words", ->
      respondToRestaurantsUI(ui.inspections.url(), data)
      ui.searchingRestaurant()
      $(".form-control").val "dimsum"
      expect($("h1")).not.toExist
      expect($("small")).not.toExist
      $(".form-control").trigger(e)
      fakeServer.respond()
      expect($("h1")).toExist
      expect($("small")).toExist
      console.log $("h1")
      expect($("h1")).toContainText "dimsum"
      expect($("small")).toContainText "The Loop"

    it "Show data on table after submit search words", ->
      respondToRestaurantsUI(ui.inspections.url(), data)
      ui.searchingRestaurant()
      $(".form-control").val "dimsum"
      expect($("tr")).not.toExist
      expect($("td")).not.toExist
      $(".form-control").trigger(e)
      fakeServer.respond()
      expect($("tr")).toExist
      expect($("td")).toExist
      expect($("td")).toContainText "dirty"
      expect($("td")).toContainText "2013-10-05"

    it "show warnning message if search word is not in data, after search", ->
      expect($("p")).not.toExist
      ui.restaurantName = "Pizza"
      fakeServer.respondWith('GET', url, [204, {'content-type': 'application/json'}, JSON.stringify([])])
      ui.searchingRestaurant()
      $(".form-control").trigger(e)
      fakeServer.respond()
      expect($("p")).toContainText "No results for"

  describe "Test resetSearchResult function", ->
    it "resetSearchResult function", ->
      ui.resetSearchResult()

    it "reset <tbody><tbody>", ->
      $(".title").prepend '<p class="bg-danger">danger</p>'
      $("tbody").append "<tr><td>hi</td></tr>"
      expect($(".bg-danger")).toExist
      expect($("td")).toExist
      expect($("tbody")).toHaveText "hi"
      ui.resetSearchResult()
      expect($(".bg-danger")).not.toExist
      expect($("td")).not.toExist
      expect($("tbody")).not.toHaveText "hi"

    it "reset textbox value", ->
      $(".form-control").val "dimsum"
      expect($(".form-control")).toHaveValue "dimsum"
      ui.resetSearchResult()
      expect($(".form-control")).toBeEmpty

  describe "Test goBackHome function", ->
    it "call functions after click", ->
      resetSearchResult = spyOn(ui, "resetSearchResult")
      getInspectionsDataOnGoogleMap = spyOn(ui, "getInspectionsDataOnGoogleMap")
      ui.goBackHome()
      $(".navbar-brand").click()
      expect(resetSearchResult).toHaveBeenCalled
      expect(getInspectionsDataOnGoogleMap).toHaveBeenCalled

  describe "Test replaceViolations and resetDate functions", ->
    it "'|' change to <br> if data has '|'", ->
      data = [{"dba_name": "yolk", "address": "The Loop", "violations": "dirty | smell"}]
      expect(data[0].violations).toBe("dirty | smell")
      result = ui.replaceViolations(data[0])
      expect(result).toEqual("dirty<br>smell")

    it "Data format is year-month-date", ->
      data = [{"dba_name": "yolk", "inspection_date": "2014-04-16T00:00:00", "violations": "dirty | smell"}]
      expect(data[0].inspection_date).toBe("2014-04-16T00:00:00")
      result = ui.resetDate(data[0])
      expect(result).toEqual("2014-04-16")
