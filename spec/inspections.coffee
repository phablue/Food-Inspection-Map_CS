describe "Test Inspections class", ->
  inspections = null
  fakeserver = null
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
    fakeserver = sinon.fakeServer.create()

  afterEach ->
    fakeserver.restore();

  respondWithDataServer: (url, data) ->
    fakeServer.respondWith('GET', url, [200, {'content-type': 'application/json'}, JSON.stringify(data)])

  describe "Test urlByName function", ->
    it "url is resourceURL, if UI restaurantName is null", ->
      inspections.ui.restaurantName = null
      url = inspections.url()
      expect(url).toBe(inspections.resourceURL)

    it "url is resourceURL?dba_name=hi, if UI restaurantName is 'hi'", ->
      inspections.ui.restaurantName = "hi"
      url = inspections.url()
      expect(url).toBe("#{inspections.resourceURL}?dba_name=hi")
