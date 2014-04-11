describe "Test UI", ->
  beforeEach ->
    setFixtures ('<div> <form class = "form-inline">
                    <input type = "text" class = "form-control" >
                    <button type = "submit" class = "btn-default">Search</button>
                  </form> </div>
                  <div class = "result">
                    <h2 class = "sub-header"></h2>
                    <h3><label>Address : </label></h3><br>
                  </div>
                  <table class="table table-striped">
                  <thead></thead>
                  <tbody></tbody> </table>')

  describe "Test searchWords function", ->
    it "Changes restaurantName value", ->
      ui = new UI
      expect(ui.restaurantName).toBeNull
      $(".form-control").val "EpicBurger"
      ui.searchWords()
      expect(ui.restaurantName).toBe "EpicBurger"

  describe "Test searchResult function", ->
    it "searchResult function", ->
      (new UI).searchResult()

    it 'Changes <h2> and <h3> text if search word in data', ->
      ui = new UI
      ui.restaurantName = "Domino pizza"
      data = [{"dba_name": ui.restaurantName, "address": "Chicago"}]
      expect($(".sub-header")).toBeEmpty
      expect($("h3")).toBeEmpty
      getJson = spyOn($, "getJSON").andReturn done: (e) -> e(data)
      ui.searchResult()
      expect($(".sub-header")).toHaveHtml ui.restaurantName
      expect($("h3")).toContainText "Chicago"

    it 'show warnning message if search word not in data', ->
      ui = new UI
      ui.restaurantName = "Pizza Hut"
      data = [{"dba_name": "Domino", "address": "South Loop"}]
      expect($("p")).not.toExist
      getJson = spyOn($, "getJSON").andReturn done: (e) -> e(data)
      ui.searchResult()
      expect($("p")).toExist

  describe "Test showResult function", ->
    it 'Changes <h2> and <h3> text if data from server is not null', ->
      ui = new UI
      ui.restaurantName = "icecream"
      data = [{"dba_name": "icecream", "address": "ChinaTown"}]
      expect($(".sub-header")).toBeEmpty
      expect($("h3")).toBeEmpty
      ui.showResult(data)
      expect($(".sub-header")).toHaveHtml ui.restaurantName
      expect($("h3")).toContainText "ChinaTown"

    it 'Changes <h2> and <h3> text if data from server is null', ->
      ui = new UI
      ui.restaurantName = "Candy"
      data = [{"dba_name": "Chocolate", "address": "DownTown"}]
      expect($("p")).not.toExist
      ui.showResult(data)
      expect($("p")).toExist

  describe "Test searchingRestaurant function", ->
    it "searchingRestaurant function", ->
      (new UI).searchingRestaurant()

    it "Changes <h2> and <h3> text after clicks a search button", ->
      ui = new UI
      data = [{"dba_name": "dimsum", "address": "The Loop"}]
      expect($(".sub-header")).toBeEmpty
      expect($("h3")).toBeEmpty
      getJson = spyOn($, "getJSON").andReturn done: (e) -> e(data)
      $(".form-control").val "dimsum"
      ui.searchingRestaurant()
      $("button").click()
      expect($(".sub-header")).toHaveHtml ui.restaurantName
      expect($("h3")).toContainText "The Loop"

    it "show warnning message if search word is not in data, after clicks a search button", ->
      ui = new UI
      data = [{"dba_name": "phatai", "address": "The Loop"}]
      expect($("p")).not.toExist
      getJson = spyOn($, "getJSON").andReturn done: (e) -> e(data)
      $(".form-control").val "dimsum"
      ui.searchingRestaurant()
      $("button").click()
      expect($("p")).toExist

  describe "Test resetSearchResult function", ->
    it "resetSearchResult function", ->
      (new UI).resetSearchResult()

    it "reset <tbody><tbody>", ->
      $(".result").prepend '<p class="bg-danger">danger</p>'
      $("tbody").append "<tr><td>hi</td></tr>"
      expect($(".bg-danger")).toExist
      expect($("td")).toExist
      expect($("tbody")).toHaveText "hi"
      (new UI).resetSearchResult()
      expect($(".bg-danger")).not.toExist
      expect($("td")).not.toExist
      expect($("tbody")).not.toHaveText "hi"
