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
                      <div class = "title"></div>
                    <table class="table table-striped">
                    <thead></thead>
                    <tbody></tbody></table></div>')

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
      url = null

      beforeEach ->
        ui.restaurantName = "Domino pizza"
        data = [{"dba_name": "Domino pizza", "address": "DownTown", "violations": "dirty", "inspection_date": "2013-10-05T00:00:00"}]
        url = "#{ui.url}?#{$.param({"dba_name": ui.restaurantName})}"

      it "searchResult function", ->
        ui.searchResult()

      it "Call showResult function if suscess get http request", ->
        respondToRestaurantsUI(url, data)
        ui.searchResult()
        fakeServer.respond()
        expect(spyOn(ui, "showResult")).toHaveBeenCalled

      it "Call setMapCSS function if data's dba_name match to restaurantName", ->
        respondToRestaurantsUI(url, data)
        ui.searchResult()
        fakeServer.respond()
        expect(spyOn(ui, "setMapCSS")).toHaveBeenCalled

      it "Call setTitle function if data's dba_name match to restaurantName", ->
        respondToRestaurantsUI(url, data)
        ui.searchResult()
        fakeServer.respond()
        expect(spyOn(ui, "setTitle")).toHaveBeenCalled

      it "Call markLocation function if data's dba_name match to restaurantName", ->
        respondToRestaurantsUI(url, data)
        ui.searchResult()
        fakeServer.respond()
        expect(spyOn(googlemap, "markLocation")).toHaveBeenCalled

      it "Call setTableBody function if data's dba_name match to restaurantName", ->
        respondToRestaurantsUI(url, data)
        ui.searchResult()
        fakeServer.respond()
        expect(spyOn(ui, "setTableBody")).toHaveBeenCalled

      it "Call noResultMessage function if data's dba_name doesnt match to restaurantName", ->
        fakeServer.respondWith('GET', url, [204, {'content-type': 'application/json'}, JSON.stringify([])])
        ui.searchResult()
        fakeServer.respond()
        expect(spyOn(ui, "noResultMessage")).toHaveBeenCalled

    describe "Test showResult function", ->
      data = null

      beforeEach ->
        ui.restaurantName = "Domino pizza"
        data = [{"dba_name": "Domino pizza", "address": "DownTown", "violations": "dirty", "inspection_date": "2013-10-05T00:00:00"}]

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
      e= null
      url = null

      beforeEach ->
        e = $.Event("submit")
        data = [{"dba_name": "dimsum", "address": "The Loop", "violations": "dirty", "inspection_date": "2013-10-05T00:00:00"}]
        url = "#{ui.url}?#{$.param({"dba_name": ui.restaurantName})}"

      it "searchingRestaurant function", ->
        ui.searchingRestaurant()

      it "call searchWords, resetSearchResult, searchResult functions clicks a search button", ->
        ui.searchingRestaurant()
        $(".form-control").trigger(e)
        expect(spyOn(ui, "searchWords")).toHaveBeenCalled
        expect(spyOn(ui, "resetSearchResult")).toHaveBeenCalled
        expect(spyOn(ui, "searchResult")).toHaveBeenCalled

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

    describe "Test SetTitle function", ->
      data = null

      beforeEach ->
        data = [{"dba_name": "dimsum", "address": "The Loop", "risk": "high", "result": "Pass", "violations": "dirty", "inspection_date": "2013-10-05T00:00:00"}]

      it "Makes <h1> and <small> Tags", ->
        expect($("h1")).not.toExist
        expect($("small")).not.toExist
        ui.setTitle(data)
        expect($("h1")).toExist
        expect($("small")).toExist

      it "Makes <h1> and <h1> has restaurantName", ->
        ui.restaurantName = "dimsum"
        expect($("h1")).not.toExist
        ui.setTitle(data)
        expect($("h1")).toExist
        expect($("h1")).toContainText "dimsum"

      it "Makes <small> and <small> has address from data", ->
        expect($("small")).not.toExist
        ui.setTitle(data)
        expect($("small")).toExist
        expect($("small")).toContainText "The Loop"

    describe "Test setTableHead function", ->
      it "makes <tr><th> tag", ->
        expect($("tr, th")).not.toExist
        ui.setTableHead()
        expect($("tr, th")).toExist

      it "thead has <tr><th>", ->
        expect($("tr, th")).not.toExist
        ui.setTableHead()
        expect($("thead")).toHaveHtml """<tr>
                                            <th>#</th>
                                            <th>Inspection Type</th>
                                            <th>Inspection Date</th>
                                            <th>Risk</th>
                                            <th>Results</th>
                                            <th>Violations</th>
                                        </tr>"""

    describe "Test setTableBody function", ->
      data = null

      beforeEach ->
        data = [{"dba_name": "dimsum", "inspection_type": "something","address": "The Loop", "risk": "high", "results": "Pass", "violations": "dirty", "inspection_date": "2013-10-05T00:00:00"}]

      it "Makes <tr> <td> tag", ->
        expect($("tr")).not.toExist
        expect($("td")).not.toExist
        ui.setTableBody(data, 0)
        expect($("tr")).toExist
        expect($("td")).toExist

      it "tbody has <tr> and each <td> has data values", ->
        expect($("tbody")).toHaveHtml ""
        ui.setTableBody(data, 0)
        expect($("tbody")).toHaveHtml """<tr><td>1</td><td>something</td><td>
                                          2013-10-05</td><td>high</td><td>Pass
                                          </td><td>dirty</td></tr>"""

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
        resetSearchResult = spyOn(ui, "resetSearchResult")
        findDirtyRestaurants = spyOn(ui, "findDirtyRestaurants")
        ui.goBackHome()
        $(".navbar-brand").click()
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
