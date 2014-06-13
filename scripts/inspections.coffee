class Inspections extends Backbone.Collection
  initialize: (options) ->
    @ui = options.ui
    @google = options.google
    @offset = 0
    @resourceURL = "https://data.cityofchicago.org/resource/4ijn-s7e5.json?$where=violations IS NOT NULL"

  url: ->
    @urlConfig()

  urlConfig: ->
    if !_.isEmpty(@ui.searchWords())
      return "#{@resourceURL}&$q=#{encodeURIComponent @ui.searchWords()}"
    else if !_.isNull(@ui.restaurantID)
      return "#{@resourceURL}&license_=#{@ui.restaurantID}"
    "#{@resourceURL}&$q=2014"

  changeOffSet: ->
    @offset += 1000

  gatherAllRestaurants: ->
    allRestaurants = new Backbone.Collection
    @fetch
      success: =>
        allRestaurants.add(@models)
        @changeOffSet()

  restaurantsFilterBy2014Year: ->
    @filter((restaurant) -> restaurant.get("inspection_date").match(/2014-*/g))

  restaurantsFilterByKeyWords: ->
    keyWords = new RegExp("#{@ui.searchWords()}", "gi")
    @restaurantsFilterBy2014Year().filter((restaurant) -> restaurant.get("dba_name").match(keyWords))

  restaurantsFilterBy: (restaurantID) ->
    @restaurantsFilterByKeyWords().filter((restaurant) -> restaurant.get("license_") == restaurantID)

  licenseIDsOfRestaurantsViolations: ->
    licenseIDs = []
    @restaurantsFilterByKeyWords().forEach((restaurant) -> licenseIDs.push(restaurant.get("license_")))
    _.uniq(licenseIDs);

  restaurantsViolationsOnGoogleMap: (restaurantsID) ->
    googleMap = new GoogleMap(@google)
    _.each(restaurantsID, (restaurantID) =>
      restaurant = @restaurantsFilterBy(restaurantID)
      @settingForGoogleMap(googleMap, restaurant))

  settingForGoogleMap: (googleMap, data) ->
    mark = googleMap.markLocation data[0].get("latitude"), data[0].get("longitude")
    googleMap.openInfoWindow mark, data[0].toJSON(), data.length

window.Inspections = Inspections
