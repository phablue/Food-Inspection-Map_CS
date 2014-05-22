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
    it "return data, if data has violation", ->
      data = [{"dba_name": "Domino pizza", "address": "Chicago", "violations": "dirty"}]
      respondWithDataServer(inspections.url(), data)
      inspections.fetch()
      fakeServer.respond()
      result = JSON.stringify(inspections.restaurantsViolations())
      expect(result).toBe(JSON.stringify(data))

    it "return [], if data doesnt have violation", ->
      data = [{"dba_name": "Domino pizza", "address": "Chicago"}]
      respondWithDataServer(inspections.url(), data)
      inspections.fetch()
      inspections.restaurantsViolations()
      result = JSON.stringify(inspections.restaurantsViolations())
      expect(result).toBe(JSON.stringify([]))
