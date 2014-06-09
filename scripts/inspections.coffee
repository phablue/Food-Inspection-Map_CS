class Inspections extends Backbone.Collection
  initialize: (options) ->
    @ui = options.ui
    @google = options.google
    @resourceURL = "https://data.cityofchicago.org/resource/4ijn-s7e5.json?$where=violations IS NOT NULL"

  url: ->
    @urlByName()

  urlByName: ->
    if !_.isEmpty(@ui.searchWords())
      return "#{@resourceURL}&$q=#{encodeURIComponent @ui.searchWords()}"
    else if !_.isNull(@ui.restaurantID)
      return "#{@resourceURL}&license_=#{@ui.restaurantID}"
    @resourceURL

  restaurantsFilterBy2014Year: ->
    this.filter((restaurant) -> restaurant.get("inspection_date").match(/2014-*/g))

  restaurantsFilterByKeyWords: ->
    keyWords = new RegExp("#{@ui.searchWords()}", "gi")
    @restaurantsFilterBy2014Year().filter((restaurant) -> restaurant.get("dba_name").match(keyWords))

  restaurantsFilterBy: (restaurantID) ->
    @restaurantsFilterBy2014Year().filter((restaurant) -> restaurant.get("license_") == restaurantID)

  licenseIDsOfRestaurantsViolations: ->
    licenseIDs = []
    @restaurantsFilterBy2014Year().forEach((restaurant) -> licenseIDs.push(restaurant.get("license_")))
    _.uniq(licenseIDs);

  restaurantsViolationsOnGoogleMap: (restaurantsID) ->
    googleMap = new GoogleMap(@google)
    _.each(restaurantsID, (restaurantID) =>
      restaurant = @restaurantHasViolationsByLicenseID(restaurantID)
      @settingForGoogleMap(googleMap, restaurant))

  settingForGoogleMap: (googleMap, data) ->
    mark = googleMap.markLocation data[0].get("latitude"), data[0].get("longitude")
    googleMap.openInfoWindow mark, data[0].toJSON(), data.length

window.Inspections = Inspections
