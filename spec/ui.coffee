describe "Test UI", ->
  beforeEach ->
    @google = 
      maps:
        LatLng: ->
        Map: ->
        Marker: ->
        InfoWindow: ->

    setFixtures ('<div> <form>
                    <input type = "text" class = "form-control" >
                  </form> </div>
                  <div class = "result">
                    <div class = "title">
                      <h1 class = "page-header"><small></small></h1>
                    </div>
                  <table class="table table-striped">
                  <thead></thead>
                  <tbody></tbody> </table></div>')

  describe "Test findDirtyRestaurants function", ->
    it "Call getOnlyRestaurantsHasViolations function", ->
      data = [{"dba_name": "Domino pizza", "address": "Chicago"}]
      getOnlyRestaurantsHasViolations = spyOn(new UI(@google), "getOnlyRestaurantsHasViolations")
      getJson = spyOn($, "getJSON").andReturn done: (e) -> e(data)
      (new UI(@google)).findDirtyRestaurants()
      expect(getOnlyRestaurantsHasViolations).toHaveBeenCalled

  describe "Test getOnlyRestaurantsHasViolations function", ->
    it "Call googleMap function if has violations", ->
      data = [{"dba_name": "Domino pizza", "address": "Chicago", "violations": "dirty"}]
      markLocation = spyOn((new GoogleMap(@google)), "markLocation")
      openInfoWindow = spyOn((new GoogleMap(@google)), "openInfoWindow")
      (new UI(@google)).getOnlyRestaurantsHasViolations(data)
      expect(markLocation).toHaveBeenCalled
      expect(openInfoWindow).toHaveBeenCalled

    it "not Call googleMap function if has violations", ->
      data = [{"dba_name": "Domino pizza", "address": "Chicago"}]
      markLocation = spyOn((new GoogleMap(@google)), "markLocation")
      (new UI(@google)).getOnlyRestaurantsHasViolations(data)
      expect(markLocation).not.toHaveBeenCalled

  describe "Test searchWords function", ->
    it "Changes restaurantName value", ->
      ui = new UI(@google)
      expect(ui.restaurantName).toBeNull
      $(".form-control").val "EpicBurger"
      ui.searchWords()
      expect(ui.restaurantName).toBe "EpicBurger"

  describe "Test searchResult function", ->
    it "searchResult function", ->
      (new UI(@google)).searchResult()

    it 'Changes <h2> and <h3> text if search word in data', ->
      ui = new UI(@google)
      ui.restaurantName = "Domino pizza"
      data = [{"dba_name": ui.restaurantName, "address": "Chicago"}]
      expect($("small")).toBeEmpty
      expect($("h3")).toBeEmpty
      getJson = spyOn($, "getJSON").andReturn done: (e) -> e(data)
      ui.searchResult()
      expect($(".page-header")).toContainText ui.restaurantName
      expect($("small")).toContainText "Chicago"

    it 'show warnning message if search word not in data', ->
      ui = new UI(@google)
      ui.restaurantName = "Pizza Hut"
      data = [{"dba_name": "Domino", "address": "South Loop"}]
      expect($("p")).not.toExist
      getJson = spyOn($, "getJSON").andReturn done: (e) -> e(data)
      ui.searchResult()
      expect($("p")).toExist

  describe "Test showResult function", ->
    it 'Changes <h2> and <h3> text if data from server is not null', ->
      ui = new UI(@google)
      ui.restaurantName = "icecream"
      data = [{"dba_name": "icecream", "address": "ChinaTown"}]
      expect($(".page-header")).toBeEmpty
      expect($("small")).toBeEmpty
      ui.showResult(data)
      expect($(".page-header")).toContainText ui.restaurantName
      expect($("small")).toContainText "ChinaTown"

    it 'Changes <h1> and <h2> text if data from server is null', ->
      ui = new UI(@google)
      ui.restaurantName = "Candy"
      data = [{"dba_name": "Chocolate", "address": "DownTown"}]
      expect($("p")).not.toExist
      ui.showResult(data)
      expect($("p")).toExist

  describe "Test searchingRestaurant function", ->
    it "searchingRestaurant function", ->
      (new UI(@google)).searchingRestaurant()

    it "Changes <h1> text after clicks a search button", ->
      ui = new UI(@google)
      data = [{"dba_name": "dimsum", "address": "The Loop"}]
      expect($(".page-header")).toBeEmpty
      expect($("small")).toBeEmpty
      e = $.Event("submit")
      getJson = spyOn($, "getJSON").andReturn done: (e) -> e(data)
      $(".form-control").val "dimsum"
      ui.searchingRestaurant()
      $(".form-control").trigger(e)
      expect($(".page-header")).toContainText ui.restaurantName
      expect($("small")).toContainText "The Loop"

    it "show warnning message if search word is not in data, after search", ->
      ui = new UI(@google)
      data = [{"dba_name": "phatai", "address": "The Loop"}]
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
