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
    it "Call markLocation, openInfoWindow functions if has violations", ->
      data = [{"dba_name": "Domino pizza", "address": "Chicago", "violations": "dirty", "inspection_date": "2013-10-05T00:00:00"}]
      markLocation = spyOn(googlemap, "markLocation")
      openInfoWindow = spyOn(googlemap, "openInfoWindow")
      ui.getOnlyRestaurantsHasViolations(data)
      expect(markLocation).toHaveBeenCalled
      expect(openInfoWindow).toHaveBeenCalled

    it "Not markLocation, openInfoWindow functions if has no violations", ->
      data = [{"dba_name": "Domino pizza", "address": "Chicago"}]
      markLocation = spyOn(googlemap, "markLocation")
      openInfoWindow = spyOn(googlemap, "openInfoWindow")
      ui.getOnlyRestaurantsHasViolations(data)
      expect(markLocation).not.toHaveBeenCalled
      expect(openInfoWindow).not.toHaveBeenCalled

  describe "Test searchWords function", ->
    it "Changes restaurantName value", ->
      expect(ui.restaurantName).toBeNull
      $(".form-control").val "EpicBurger"
      ui.searchWords()
      expect(ui.restaurantName).toBe "EpicBurger"

  describe "Test searchResult function", ->
    it "searchResult function", ->
      (new UI(@google)).searchResult()

    it 'Changes <h1> text if search word in data', ->
      ui = new UI(@google)
      ui.restaurantName = "Domino pizza"
      data = [{"dba_name": ui.restaurantName, "address": "Chicago", "violations": "dirty", "inspection_date": "2013-10-05T00:00:00"}]
      expect($("small")).toBeEmpty
      getJson = spyOn($, "getJSON").andReturn done: (e) -> e(data)
      ui.searchResult()
      expect($(".page-header")).toContainText ui.restaurantName
      expect($("small")).toContainText "Chicago"

    it 'show warnning message if search word not in data', ->
      ui = new UI(@google)
      ui.restaurantName = "Pizza Hut"
      data = [{"dba_name": "Domino", "address": "South Loop", "violations": "dirty", "inspection_date": "2013-10-05T00:00:00"}]
      expect($("p")).not.toExist
      getJson = spyOn($, "getJSON").andReturn done: (e) -> e(data)
      ui.searchResult()
      expect($("p")).toExist

  describe "Test showResult function", ->
    it 'Changes result if data from server is not null', ->
      ui = new UI(@google)
      ui.restaurantName = "icecream"
      data = [{"dba_name": "icecream", "address": "ChinaTown", "violations": "dirty", "inspection_date": "2013-10-05T00:00:00"}]
      expect($(".page-header")).toBeEmpty
      expect($("small")).toBeEmpty
      ui.showResult(data)
      expect($(".page-header")).toContainText ui.restaurantName
      expect($("small")).toContainText "ChinaTown"

    it 'Changes result if data from server is null', ->
      ui = new UI(@google)
      ui.restaurantName = "Candy"
      data = [{"dba_name": "Chocolate", "address": "DownTown", "violations": "dirty", "inspection_date": "2013-10-05T00:00:00"}]
      expect($("p")).not.toExist
      ui.showResult(data)
      expect($("p")).toExist

  describe "Test searchingRestaurant function", ->
    it "searchingRestaurant function", ->
      (new UI(@google)).searchingRestaurant()

    it "call searchWords, resetSearchResult, searchResult functions clicks a search button", ->
      searchWords = spyOn(new UI(@google), "searchWords")
      resetSearchResult = spyOn(new UI(@google), "resetSearchResult")
      searchResult = spyOn(new UI(@google), "searchResult")
      ui = new UI(@google)
      data = [{"dba_name": "dimsum", "address": "The Loop", "violations": "dirty", "inspection_date": "2013-10-05T00:00:00"}]
      e = $.Event("submit")
      getJson = spyOn($, "getJSON").andReturn done: (e) -> e(data)
      ui.searchingRestaurant()
      $(".form-control").trigger(e)
      expect(searchWords).toHaveBeenCalled
      expect(resetSearchResult).toHaveBeenCalled
      expect(searchResult).toHaveBeenCalled

    it "show warnning message if search word is not in data, after search", ->
      ui = new UI(@google)
      data = [{"dba_name": "phatai", "address": "The Loop", "violations": "dirty", "inspection_date": "2013-10-05T00:00:00"}]
      expect($("p")).not.toExist
      getJson = spyOn($, "getJSON").andReturn done: (e) -> e(data)
      $(".form-control").val "dimsum"
      ui.searchingRestaurant()
      $("button").click()
      expect($("p")).toExist

  describe "Test resetSearchResult function", ->
    it "resetSearchResult function", ->
      (new UI(@google)).resetSearchResult()

    it "reset <tbody><tbody>", ->
      $(".title").prepend '<p class="bg-danger">danger</p>'
      $("tbody").append "<tr><td>hi</td></tr>"
      expect($(".bg-danger")).toExist
      expect($("td")).toExist
      expect($("tbody")).toHaveText "hi"
      (new UI(@google)).resetSearchResult()
      expect($(".bg-danger")).not.toExist
      expect($("td")).not.toExist
      expect($("tbody")).not.toHaveText "hi"

    it "reset textbox value", ->
      $(".form-control").val "dimsum"
      expect($(".form-control")).toHaveValue "dimsum"
      (new UI(@google)).resetSearchResult()
      expect($(".form-control")).toBeEmpty

  describe "Test hideElement and showElement function", ->
    it "hide element", ->
      expect($("h1")).toBeVisible
      (new UI(@google)).hideElement("h1")
      expect($("h1")).toBeHidden

    it "show element", ->
      $("h1").hide
      expect($("h1")).toBeHidden
      (new UI(@google)).showElement("h1")
      expect($("h1")).toBeVisible

  describe "Test howManyViolations function", ->
    it "return 1", ->
      data = [{"dba_name": "yolk", "address": "The Loop", "violations": "dirty"}]
      expect((new UI(@google)).howManyViolations(data)).toEqual(1)

    it "return 0", ->
      data = [{"dba_name": "yolk", "address": "The Loop"}]
      expect((new UI(@google)).howManyViolations(data)).toBeNull

  describe "Test checkHasViolations function", ->
    it "return true", ->
      data = [{"dba_name": "yolk", "address": "The Loop", "violations": "dirty"}]
      expect((new UI(@google)).howManyViolations(data)).toBeTruthy

    it "return false", ->
      data = [{"dba_name": "yolk", "address": "The Loop"}]
      expect((new UI(@google)).howManyViolations(data)).toBeFalsy

  describe "Test goBackHome function", ->
    it "call functions after click", ->
      hideElement = spyOn(new UI(@gogle), "hideElement")
      resetSearchResult = spyOn(new UI(@gogle), "resetSearchResult")
      findDirtyRestaurants = spyOn(new UI(@gogle), "findDirtyRestaurants")
      (new UI(@gogle)).goBackHome()
      $(".navbar-brand").click()
      expect(hideElement).toHaveBeenCalled
      expect(resetSearchResult).toHaveBeenCalled
      expect(findDirtyRestaurants).toHaveBeenCalled

  describe "Test replaceString and resetDate functions", ->
    it "'|' change to <br> if data has '|'", ->
      data = [{"dba_name": "yolk", "address": "The Loop", "violations": "dirty | smell"}]
      expect(data[0].violations).toBe("dirty | smell")
      result = (new UI(@google)).replaceString(data, 0)
      expect(result).toEqual("dirty<br>smell")

    it "Data format is year-month-date", ->
      data = [{"dba_name": "yolk", "inspection_date": "2014-04-16T00:00:00", "violations": "dirty | smell"}]
      expect(data[0].inspection_date).toBe("2014-04-16T00:00:00")
      result = (new UI(@google)).resetDate(data, 0)
      expect(result).toEqual("2014-04-16")
