describe "Test UI", ->
  beforeEach ->
    setFixtures ('<div> <form class = "form-inline"> \
                    <input type = "text" class = "form-control" > \
                    <button type = "submit" class = "btn-default">Search</button> \
                  </form> </div> \
                  <div class = "result"></div>')

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

    it 'Changes <div class = "result"></div> text', ->
      ui = new UI
      ui.restaurantName = "Domino pizza"
      data = {"dba_name": ui.restaurantName}
      expect($(".result")).toBeEmpty
      getJson = spyOn($, "getJSON").andReturn done: (e) -> e(data)
      ui.searchResult()
      expect($(".result")).toHaveHtml ui.restaurantName

  describe "Test showResult function", ->
    it 'Changes <div class = "result"></div> text', ->
      data = {"dba_name": "icecream"}
      expect($(".result")).toBeEmpty
      (new UI).showResult(data)
      expect($(".result")).toHaveHtml "icecream"