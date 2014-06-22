describe "Test Inspections class", ->
  inspections = null
  fakeServer = null
  google = null

  beforeEach ->
    setFixtures ('<form>
                    <input type="text" class="form-control" data-id="searchWord" placeholder="Search...">
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
    fakeServer.restore()

  respondWithDataServer = (url, data) ->
    fakeServer.respondWith('GET', url, [200, {'content-type': 'application/json'}, JSON.stringify(data)])

  getRequestfromDataServer = (data) ->
    inspections.fetch()
    respondWithDataServer(inspections.url(), data)
    fakeServer.respond()

  describe "Test FilterByKeyWordsFor function", ->
    data = [{license_: "123", dba_name: "Domino pizza", address: "Chicago", violations: "dirty", inspection_date: "2014-10-05T00:00:00"},
            {license_: "456", dba_name: "Pizza Hut", address: "Downtown", violations: "dirty", inspection_date: "2014-10-05T00:00:00"}]

    it "Return result length is 2 if search word is 'pizza'", ->
      $("[data-id='searchWord']").val "pizza"

      getRequestfromDataServer(data)
      result = inspections.filterByKeyWordsFor(inspections)

      expect(result.length).toBe 2

    it "Return result length is 1 if search word is 'hut'", ->
      $("[data-id='searchWord']").val "hut"

      getRequestfromDataServer(data)
      result = inspections.filterByKeyWordsFor(inspections)

      expect(result.length).toBe 1

  describe "Test urlConfig function", ->
    it "url is resourceURL, if UI searchWord is empty", ->
      url = inspections.url()

      expect(url).toBe("#{inspections.resourceURL}&$offset=0")

    it "url is resourceURL?&$q=hi, if searchWord is 'hi'", ->
      $("[data-id='searchWord']").val "hi"

      url = inspections.url()

      expect(url).toBe("#{inspections.resourceURL}&$q=hi")

    it "url is resourceURL?&$q=123, if UI searchWord is '123'", ->
      $("[data-id='searchWord']").val "123"

      url = inspections.url()

      expect(url).toBe("#{inspections.resourceURL}&$q=123")

  describe "Test searchInURL function", ->
    it "Bigger than -1 if 'offset' include url address", ->
      result = inspections.searchInURL('offset')

      expect(result).toBe > -1

    it "Return -1 if 'offset' not include url address", ->
      $("[data-id='searchWord']").val "123"

      result = inspections.searchInURL('offset')

      expect(result).toBe -1

  describe "Test restaurantsFilterBy function", ->
    beforeEach ->
      data = [{license_: "123", dba_name: "Domino pizza", address: "Chicago", violations: "dirty", inspection_date: "2014-10-05T00:00:00"},
              {license_: "456", dba_name: "Pizza Hut", address: "Downtown", violations: "dirty", inspection_date: "2014-10-05T00:00:00"}]

      getRequestfromDataServer(data)
      inspections.fetch()

    it "Return data dba_name is Domino pizza if restaurantID is 123", ->
      result = inspections.restaurantsFilterBy(inspections.models, "123")

      expect(result[0].get("dba_name")).toEqual("Domino pizza")

    it "Return data is null if restaurantID is 567", ->
      result = inspections.restaurantsFilterBy(inspections.models, "567")

      expect(result).toBeNull

  describe "Test licenseIDsOf function", ->
    it "Return only license_ ['Chicago', 'Seattle'] in data", ->
      data = [{license_: "Chicago", dba_name: "Pizza", violations: "dirty", inspection_date: "2014-10-05T00:00:00"}, {license_: "Seattle", dba_name: "Pizza", violations: "Too dirty", inspection_date: "2014-10-05T00:00:00"}]
      $("[data-id='searchWord']").val "pizza"

      getRequestfromDataServer(data)
      inspections.fetch
      
      result = inspections.licenseIDsOf(inspections)

      expect(result.length).toBe 2
      expect(result).toEqual(["Chicago", "Seattle"])

    it "Return ['Seoul'] in data after delete duplications", ->
      $("[data-id='searchWord']").val "pizza"
      data = [{license_: "Seoul", dba_name: "Pizza", violations: "dirty", inspection_date: "2014-10-05T00:00:00"}, {license_: "Seoul", dba_name: "Pizza", violations: "Too dirty", inspection_date: "2014-10-05T00:00:00"}]

      getRequestfromDataServer(data)
      inspections.fetch
      
      result = inspections.licenseIDsOf(inspections)

      expect(result.length).toBe 1
      expect(result).toEqual(["Seoul"])
