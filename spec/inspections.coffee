describe "Test Inspections class", ->
  inspections = null
  fakeServer = null
  google = null

  beforeEach ->
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
      respondWithDataServer(inspections.url(), data)
      inspections.fetch()
      fakeServer.respond()
      result = inspections.restaurantsFilterBy2014Year()
      expect(result.length).toBe 1
      expect(result[0].get("dba_name")).toBe "Pizza Hut"

    it "Return 0 if if inspection_date contain 2014", ->
      data = [{dba_name: "Domino pizza", address: "Chicago", violations: "dirty", inspection_date: "2013-10-05T00:00:00"}]
      respondWithDataServer(inspections.url(), data)
      inspections.fetch()
      fakeServer.respond()
      result = inspections.restaurantsFilterBy2014Year()
      expect(result.length).toBe 0

  describe "Test urlByName function", ->
    it "url is resourceURL, if UI restaurantName is null", ->
      expect(inspections.ui.restaurantName).toBeNull()
      url = inspections.url()
      expect(url).toBe(inspections.resourceURL)

    it "url is resourceURL?dba_name=hi, if UI restaurantName is 'hi'", ->
      inspections.ui.restaurantName = "hi"
      url = inspections.url()
      expect(url).toBe("#{inspections.resourceURL}&dba_name=hi")

    it "url is resourceURL?dba_name=123, if UI restaurantID is '123'", ->
      inspections.ui.restaurantName = "123"
      url = inspections.url()
      expect(url).toBe("#{inspections.resourceURL}&dba_name=123")      

  describe "Test licenseIDsOfRestaurantsViolations function", ->
    it "Return only license_ ['Chicago', 'Seattle'] in data", ->
      data = [{"license_": "Chicago", "violations": "dirty", "inspection_date": "2014-10-05T00:00:00"}, {"license_": "Seattle", "violations": "Too dirty", "inspection_date": "2014-10-05T00:00:00"}]
      respondWithDataServer(inspections.url(), data)
      inspections.fetch()
      fakeServer.respond()
      result = inspections.licenseIDsOfRestaurantsViolations()
      expect(result.length).toBe 2
      expect(result).toEqual(["Chicago", "Seattle"])

    it "Return ['Seoul'] in data after delete duplications", ->
      data = [{"license_": "Seoul", "violations": "dirty", "inspection_date": "2014-10-05T00:00:00"}, {"license_": "Seoul", "violations": "Too dirty", "inspection_date": "2014-10-05T00:00:00"}]
      respondWithDataServer(inspections.url(), data)
      inspections.fetch()
      fakeServer.respond()
      result = inspections.licenseIDsOfRestaurantsViolations()
      expect(result.length).toBe 1
      expect(result).toEqual(["Seoul"])
