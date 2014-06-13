describe "Test Inspections class", ->
  inspections = null
  fakeServer = null
  google = null

  beforeEach ->
    setFixtures ('<form>
                    <input type="text" class="form-control" placeholder="Search...">
                  </form>')
    google = 
      maps:
        LatLng: ->
        Map: ->
          setCenter: ->
        Marker: ->
        InfoWindow: ->
        event: ->
          addListener: ->

    inspections = new Inspections({google: google, ui: new UI()})
    fakeServer = sinon.fakeServer.create()

  afterEach ->
    fakeServer.restore();

  respondWithDataServer = (url, data) ->
    fakeServer.respondWith('GET', url, [200, {'content-type': 'application/json'}, JSON.stringify(data)])

  describe "Test restaurantsFilterBy2014Year function", ->
    it "Return 1 if if inspection_date contain 2014", ->
      data = [{dba_name: "Domino pizza", address: "Chicago", violations: "dirty", inspection_date: "2013-10-05T00:00:00"},
              {dba_name: "Pizza Hut", address: "Downtown", violations: "dirty", inspection_date: "2014-10-05T00:00:00"}]
      inspections.fetch()
      respondWithDataServer(inspections.url(), data)
      fakeServer.respond()
      result = inspections.restaurantsFilterBy2014Year()
      expect(result.length).toBe 1
      expect(result[0].get("dba_name")).toBe "Pizza Hut"

    it "Return 0 if if inspection_date contain 2014", ->
      data = [{dba_name: "Domino pizza", address: "Chicago", violations: "dirty", inspection_date: "2013-10-05T00:00:00"}]
      inspections.fetch()
      respondWithDataServer(inspections.url(), data)
      fakeServer.respond()
      result = inspections.restaurantsFilterBy2014Year()
      expect(result.length).toBe 0

  describe "Test restaurantsFilterByKeyWords function", ->
    data = null

    beforeEach ->
      data = [{license_: "123", dba_name: "Domino pizza", address: "Chicago", violations: "dirty", inspection_date: "2014-10-05T00:00:00"},
              {license_: "456", dba_name: "Pizza Hut", address: "Downtown", violations: "dirty", inspection_date: "2014-10-05T00:00:00"}]

    it "Return result length is 2 if search word is 'pizza'", ->
      $(".form-control").val "pizza"
      inspections.fetch()
      respondWithDataServer(inspections.url(), data)
      fakeServer.respond()
      result = inspections.restaurantsFilterByKeyWords()
      expect(result.length).toBe 2

    it "Return result length is 1 if search word is 'hut'", ->
      $(".form-control").val "hut"
      inspections.fetch()
      respondWithDataServer(inspections.url(), data)
      fakeServer.respond()
      result = inspections.restaurantsFilterByKeyWords()
      expect(result.length).toBe 1

  describe "Test urlConfig function", ->
    url = inspections.url()

    it "url is resourceURL, if UI searchWord is empty", ->
      expect(url).toBe(inspections.resourceURL)

    it "url is resourceURL?&$q=hi, if searchWord is 'hi'", ->
      $(".form-control").val "hi"

      expect(url).toBe("#{inspections.resourceURL}&$q=hi")

    it "url is resourceURL?&$q=123, if UI searchWord is '123'", ->
      $(".form-control").val "123"

      expect(url).toBe("#{inspections.resourceURL}&$q=123")

  describe "Test restaurantsFilterBy function", ->
    beforeEach ->
      data = [{license_: "123", dba_name: "Domino pizza", address: "Chicago", violations: "dirty", inspection_date: "2014-10-05T00:00:00"},
              {license_: "456", dba_name: "Pizza Hut", address: "Downtown", violations: "dirty", inspection_date: "2014-10-05T00:00:00"}]
      inspections.fetch()
      respondWithDataServer(inspections.url(), data)
      fakeServer.respond()

    it "Return data dba_name is Domino pizza if restaurantID is 123", ->
      result = inspections.restaurantsFilterBy("123")
      expect(result[0].get("dba_name")).toEqual("Domino pizza")

    it "Return data is null if restaurantID is 567", ->
      result = inspections.restaurantsFilterBy("567")
      expect(result).toBeNull

  describe "Test licenseIDsOfRestaurantsViolations function", ->
    it "Return only license_ ['Chicago', 'Seattle'] in data", ->
      data = [{license_: "Chicago", dba_name: "Pizza", violations: "dirty", inspection_date: "2014-10-05T00:00:00"}, {license_: "Seattle", dba_name: "Pizza", violations: "Too dirty", inspection_date: "2014-10-05T00:00:00"}]
      $(".form-control").val "pizza"
      inspections.fetch()
      respondWithDataServer(inspections.url(), data)
      fakeServer.respond()
      result = inspections.licenseIDsOfRestaurantsViolations()
      expect(result.length).toBe 2
      expect(result).toEqual(["Chicago", "Seattle"])

    it "Return ['Seoul'] in data after delete duplications", ->
      $(".form-control").val "pizza"
      data = [{license_: "Seoul", dba_name: "Pizza", violations: "dirty", inspection_date: "2014-10-05T00:00:00"}, {license_: "Seoul", dba_name: "Pizza", violations: "Too dirty", inspection_date: "2014-10-05T00:00:00"}]
      inspections.fetch()
      respondWithDataServer(inspections.url(), data)
      fakeServer.respond()
      result = inspections.licenseIDsOfRestaurantsViolations()
      expect(result.length).toBe 1
      expect(result).toEqual(["Seoul"])
