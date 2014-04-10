describe "Test UI", ->
  beforeEach ->
    setFixtures ('<div> <form class = "form-inline">
                    <input type = "text" class = "form-control" >
                    <button type = "submit" class = "btn-default">Search</button>
                  </form> </div>
                  <div class = "result">
                    <h2 class = "sub-header"></h2>
                    <h3><label>Address : </label></h3><br>
                  </div>')

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

    it 'Changes <h2> and <h3> text', ->
      ui = new UI
      ui.restaurantName = "Domino pizza"
      data = [{"dba_name": ui.restaurantName, "address": "Chicago"}]
      expect($(".sub-header")).toBeEmpty
      expect($("h3")).toBeEmpty
      getJson = spyOn($, "getJSON").andReturn done: (e) -> e(data)
      ui.searchResult()
      expect($(".sub-header")).toHaveHtml ui.restaurantName
      expect($("h3")).toContainText "Chicago"

  describe "Test showResult function", ->
    it 'Changes <h2> and <h3> text', ->
      ui = new UI
      ui.restaurantName = "Domino pizza"
      data = [{"dba_name": "icecream", "address": "ChinaTown"}]
      expect($(".sub-header")).toBeEmpty
      expect($("h3")).toBeEmpty
      ui.showResult(data)
      expect($(".sub-header")).toHaveHtml ui.restaurantName
      expect($("h3")).toContainText "ChinaTown"

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
