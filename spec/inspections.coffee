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

    inspections = new Inspections(google, new UI())
    fakeServer = sinon.fakeServer.create()

  afterEach ->
    fakeServer.restore();

  respondWithDataServer = (url, data) ->
    fakeServer.respondWith('GET', url, [200, {'content-type': 'application/json'}, JSON.stringify(data)])

  it "fakeServer requests length is 1, if success to do fetch()", ->
    data = [{"dba_name": "Domino pizza", "address": "Chicago", "violations": "dirty"}]
    respondWithDataServer(inspections.url(), data)
    inspections.fetch()
    fakeServer.respond()
    expect(fakeServer.requests.length).toBe 1

  it "fakeServer requests length is 1, if dosnt do fetch()", ->
    data = [{"dba_name": "Domino pizza", "address": "Chicago", "violations": "dirty"}]
    respondWithDataServer(inspections.url(), data)
    fakeServer.respond()
    expect(fakeServer.requests.length).toBe 0

  describe "Test urlByName function", ->
    it "url is resourceURL, if UI restaurantName is null", ->
      expect(inspections.ui.restaurantName).toBeNull()
      url = inspections.url()
      expect(url).toBe(inspections.resourceURL)

    it "url is resourceURL?dba_name=hi, if UI restaurantName is 'hi'", ->
      inspections.ui.restaurantName = "hi"
      url = inspections.url()
      expect(url).toBe("#{inspections.resourceURL}?dba_name=hi")

  describe "Test restaurantsViolations function", ->
    it "Return data, if data has violation", ->
      data = [{"dba_name": "Domino pizza", "address": "Chicago", "violations": "dirty"}]
      respondWithDataServer(inspections.url(), data)
      inspections.fetch()
      fakeServer.respond()
      result = JSON.stringify(inspections.restaurantsViolations())
      expect(result).toBe(JSON.stringify(data))

    it "Return [], if data doesnt have violation", ->
      data = [{"dba_name": "Domino pizza", "address": "Chicago"}]
      respondWithDataServer(inspections.url(), data)
      inspections.fetch()
      fakeServer.respond()
      result = JSON.stringify(inspections.restaurantsViolations())
      expect(result).toBe(JSON.stringify([]))

  describe "Test licenseIDsOfRestaurantsViolations function", ->
    it "Return only license_ ['Chicago', 'Seattle'] in data", ->
      data = [{"license_": "Chicago", "violations": "dirty"}, {"license_": "Seattle", "violations": "Too dirty"}]
      respondWithDataServer(inspections.url(), data)
      inspections.fetch()
      fakeServer.respond()
      result = inspections.licenseIDsOfRestaurantsViolations()
      expect(result.length).toBe 2
      expect(result).toEqual(["Chicago", "Seattle"])

    it "Return ['Seoul'] in data after delete duplications", ->
      data = [{"license_": "Seoul", "violations": "dirty"}, {"license_": "Seoul", "violations": "Too dirty"}]
      respondWithDataServer(inspections.url(), data)
      inspections.fetch()
      fakeServer.respond()
      result = inspections.licenseIDsOfRestaurantsViolations()
      expect(result.length).toBe 1
      expect(result).toEqual(["Seoul"])
