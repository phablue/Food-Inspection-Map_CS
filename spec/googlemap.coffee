describe "Test GoogleMap", ->
  beforeEach ->
    @google = 
      maps:
        LatLng: ->
        Map: ->
        Marker:
          position: null
          map: null
        InfoWindow:
          content: null
      close: ->

  describe "Test CheckCurrentWindow function", ->
    it "Changes to currentMark value if current mark is null", ->
      googlemap = new GoogleMap(@google)
      infoWindows = {id: "123"}
      googlemap.currentMark = null
      googlemap.checkCurrentWindow(infoWindows)
      expect(googlemap.currentMark).toEqual("123")
