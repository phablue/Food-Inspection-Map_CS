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

    setFixtures ('<div>
                  <a class = "navbar-brand">Dirty Restaurant in Chicago</a>
                  <form>
                    <input type = "text" class = "form-control" >
                  </form> </div>
                  <div class = "result">
                    <div class = "title">
                      <h1 class = "page-header"></h1>
                    </div>
                  <table class="table table-striped">
                  <thead></thead>
                  <tbody></tbody> </table></div>')

    fakeServer = sinon.fakeServer.create()
    ui = new UI(@google)
    googlemap = new GoogleMap(@google)

  afterEach ->
    fakeServer.restore()

  respondToRestaurantsUI = (url, data) ->
    fakeServer.respondWith('GET', url, [200, {'content-type': 'application/json'}, JSON.stringify(data)])

  describe "Test findDirtyRestaurants function", ->
    it "Call getOnlyRestaurantsHasViolations function", ->
      data = [{"dba_name": "Domino pizza", "address": "Chicago"}]
      respondToRestaurantsUI(ui.url, data)
      ui.findDirtyRestaurants()
      fakeServer.respond()
      expect(spyOn(ui, "getOnlyRestaurantsHasViolations")).toHaveBeenCalled

  describe "Test getOnlyRestaurantsHasViolations function", ->
    it "Call getJSON if data has violations", ->
      data = [{"dba_name": "Domino pizza", "address": "Chicago", "violations": "dirty", "inspection_date": "2013-10-05T00:00:00"}]
      ui.getOnlyRestaurantsHasViolations(data)
      expect(spyOn($, "getJSON")).toHaveBeenCalled

    it "Does not call getJSON if data doesnt have violations", ->
      data = [{"dba_name": "Domino pizza", "address": "Chicago"}]
      ui.getOnlyRestaurantsHasViolations(data)
      expect(spyOn($, "getJSON")).not.toHaveBeenCalled

    it "Call markLocation and openInfoWindow function from googleMap, if data has violations", ->
      data = [{"dba_name": "Domino pizza", "address": "Chicago", "violations": "dirty","inspection_date": "2013-10-05T00:00:00", "latitude": "40.523", "longitude": "80.2342"}]
      url = ui.url+"?"+$.param({"dba_name": "Domino pizza"})
      respondToRestaurantsUI(url, data)
      ui.getOnlyRestaurantsHasViolations(data)
      fakeServer.respond()
      expect(spyOn(googlemap, "markLocation")).toHaveBeenCalled
      expect(spyOn(googlemap, "openInfoWindow")).toHaveBeenCalled

  describe "Test searchWords function", ->
    it "Changes restaurantName value", ->
      expect(ui.restaurantName).toBeNull
      $(".form-control").val "EpicBurger"
      ui.searchWords()
      expect(ui.restaurantName).toBe "EpicBurger"

  describe "Test searchResult function", ->
    data = null

    beforeEach ->
      data = [{"dba_name": ui.restaurantName, "address": "DownTown", "violations": "dirty", "inspection_date": "2013-10-05T00:00:00"}]

    it "searchResult function", ->
      ui.searchResult()

    it "Call showResult function if suscess get http request", ->
      ui.restaurantName = "Domino pizza"
      url = ui.url+"?"+$.param({"dba_name": ui.restaurantName})
      respondToRestaurantsUI(url, data)
      ui.searchResult()
      fakeServer.respond()
      expect(spyOn(ui, "showResult")).toHaveBeenCalled

    it "Text in <h1> changes to restaurantName if data's dba_name match to restaurantName", ->
      ui.restaurantName = "Domino pizza"
      expect($(".page-header")).toBeEmpty
      url = ui.url+"?"+$.param({"dba_name": ui.restaurantName})
      respondToRestaurantsUI(url, data)
      ui.searchResult()
      fakeServer.respond()
      expect($(".page-header")).toContainText ui.restaurantName

    it "Makes <small> tag if data's dba_name match to restaurantName", ->
      ui.restaurantName = "Domino pizza"
      expect($("small")).not.toExist
      url = ui.url+"?"+$.param({"dba_name": ui.restaurantName})
      respondToRestaurantsUI(url, data)
      ui.searchResult()
      fakeServer.respond()
      expect($("small")).toExist

    it "Text in <small> is address if data's dba_name match to restaurantName", ->
      ui.restaurantName = "Domino pizza"
      expect($("small")).toBeEmpty
      url = ui.url+"?"+$.param({"dba_name": ui.restaurantName})
      respondToRestaurantsUI(url, data)
      ui.searchResult()
      fakeServer.respond()
      expect($("small")).toContainText "DownTown"      

    it 'Makes <p> tag for warnning message if search word not in data', ->
      ui.restaurantName = "Pizza Hut"
      expect($("p")).not.toExist
      url = ui.url+"?"+$.param({"dba_name": ui.restaurantName})
      fakeServer.respondWith('GET', url, [204, {'content-type': 'application/json'}, JSON.stringify([])])
      ui.searchResult()
      fakeServer.respond()
      expect($("p")).toExist

    it 'Text in <p> has a warnning message if search word not in data', ->
      ui.restaurantName = "Pizza Hut"
      expect($("p")).not.toExist
      url = ui.url+"?"+$.param({"dba_name": ui.restaurantName})
      fakeServer.respondWith('GET', url, [204, {'content-type': 'application/json'}, JSON.stringify([])])
      ui.searchResult()
      fakeServer.respond()
      expect($("p")).toContainText "No results for"

  describe "Test showResult function", ->
    it 'Changes result if data from server is not null', ->
      ui.restaurantName = "icecream"
      data = [{"dba_name": "icecream", "address": "ChinaTown", "violations": "dirty", "inspection_date": "2013-10-05T00:00:00"}]
      expect($(".page-header")).toBeEmpty
      expect($("small")).toBeEmpty
      ui.showResult(data)
      expect($(".page-header")).toContainText ui.restaurantName
      expect($("small")).toContainText "ChinaTown"

    it 'Changes result if data from server is null', ->
      ui.restaurantName = "Candy"
      data = [{"dba_name": "Chocolate", "address": "DownTown", "violations": "dirty", "inspection_date": "2013-10-05T00:00:00"}]
      expect($("p")).not.toExist
      ui.showResult(data)
      expect($("p")).toExist

  describe "Test searchingRestaurant function", ->
    it "searchingRestaurant function", ->
      ui.searchingRestaurant()

    it "call searchWords, resetSearchResult, searchResult functions clicks a search button", ->
      searchWords = spyOn(ui, "searchWords")
      resetSearchResult = spyOn(ui, "resetSearchResult")
      searchResult = spyOn(ui, "searchResult")
      data = [{"dba_name": "dimsum", "address": "The Loop", "violations": "dirty", "inspection_date": "2013-10-05T00:00:00"}]
      e = $.Event("submit")
      getJson = spyOn($, "getJSON").andReturn done: (e) -> e(data)
      ui.searchingRestaurant()
      $(".form-control").trigger(e)
      expect(searchWords).toHaveBeenCalled
      expect(resetSearchResult).toHaveBeenCalled
      expect(searchResult).toHaveBeenCalled

    it "show warnning message if search word is not in data, after search", ->
      data = [{"dba_name": "phatai", "address": "The Loop", "violations": "dirty", "inspection_date": "2013-10-05T00:00:00"}]
      expect($("p")).not.toExist
      getJson = spyOn($, "getJSON").andReturn done: (e) -> e(data)
      $(".form-control").val "dimsum"
      ui.searchingRestaurant()
      $("button").click()
      expect($("p")).toExist

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

  describe "Test hideElement and showElement function", ->
    it "hide element", ->
      expect($("h1")).toBeVisible
      ui.hideElement("h1")
      expect($("h1")).toBeHidden

    it "show element", ->
      $("h1").hide
      expect($("h1")).toBeHidden
      ui.showElement("h1")
      expect($("h1")).toBeVisible

  describe "Test howManyViolations function", ->
    it "return 1", ->
      data = [{"dba_name": "yolk", "address": "The Loop", "violations": "dirty"}]
      expect(ui.howManyViolations(data)).toEqual(1)

    it "return 0", ->
      data = [{"dba_name": "yolk", "address": "The Loop"}]
      expect(ui.howManyViolations(data)).toBeNull

  describe "Test checkHasViolations function", ->
    it "return true", ->
      data = [{"dba_name": "yolk", "address": "The Loop", "violations": "dirty"}]
      expect(ui.howManyViolations(data)).toBeTruthy

    it "return false", ->
      data = [{"dba_name": "yolk", "address": "The Loop"}]
      expect(ui.howManyViolations(data)).toBeFalsy

  describe "Test goBackHome function", ->
    it "call functions after click", ->
      hideElement = spyOn(ui, "hideElement")
      resetSearchResult = spyOn(ui, "resetSearchResult")
      findDirtyRestaurants = spyOn(ui, "findDirtyRestaurants")
      ui.goBackHome()
      $(".navbar-brand").click()
      expect(hideElement).toHaveBeenCalled
      expect(resetSearchResult).toHaveBeenCalled
      expect(findDirtyRestaurants).toHaveBeenCalled

  describe "Test replaceString and resetDate functions", ->
    it "'|' change to <br> if data has '|'", ->
      data = [{"dba_name": "yolk", "address": "The Loop", "violations": "dirty | smell"}]
      expect(data[0].violations).toBe("dirty | smell")
      result = ui.replaceString(data, 0)
      expect(result).toEqual("dirty<br>smell")

    it "Data format is year-month-date", ->
      data = [{"dba_name": "yolk", "inspection_date": "2014-04-16T00:00:00", "violations": "dirty | smell"}]
      expect(data[0].inspection_date).toBe("2014-04-16T00:00:00")
      result = ui.resetDate(data, 0)
      expect(result).toEqual("2014-04-16")
