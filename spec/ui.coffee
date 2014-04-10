describe "Test UI", ->
  beforeEach ->
    setFixtures ('<div> <form class = "form-inline"> \
                    <input type = "text" class = "form-control" > \
                    <button type = "submit" class = "btn-default">Search</button> \
                  </form> </div> \
                  <div class = "result"></div>')

  describe "Test searchRestaurant function", ->
    it "Changes restaurantName value", ->
      ui = new UI
      expect(ui.restaurantName).toBeNull
      $(".form-control").val "EpicBurger"
      ui.searchRestaurant()
      expect(ui.restaurantName).toBe "EpicBurger"

  describe "Test getData function", ->
    it "getData function", ->
      (new UI).getData()

    it 'Changes <div class = "result"></div> text', ->
      ui = new UI
      ui.restaurantName = "Domino pizza"
      data = {"dba_name": @restaurantName}
      expect($(".result")).toBeEmpty
