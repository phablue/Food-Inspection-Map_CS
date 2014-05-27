class Inspections extends Backbone.Collection
  initialize: (options) ->
    @ui = options.ui
    @google = options.google
    @resourceURL = "https://data.cityofchicago.org/resource/4ijn-s7e5.json?$where=violations IS NOT NULL"

  url: ->
    @urlByName()

  urlByName: ->
    unless _.isNull(@ui.restaurantName)
      return "#{@resourceURL}&dba_name=#{encodeURIComponent @ui.restaurantName}"
    @resourceURL

  restaurantHasViolationsByLicenseID: (restaurantLicenseID) ->
    @restaurantsViolations().filter((restaurant) -> restaurant.get("license_") == restaurantLicenseID)

  licenseIDsOfRestaurantsViolations: ->
    licenseIDs = []
    @restaurantsViolations().forEach((restaurant) -> licenseIDs.push(restaurant.get("license_")))
    _.uniq(licenseIDs);

  restaurantsViolationsOnGoogleMap: ->
    googleMap = new GoogleMap(@google)
    _.each(@licenseIDsOfRestaurantsViolations(), (restaurantLicenseID) =>
      restaurant = @restaurantHasViolationsByLicenseID(restaurantLicenseID)
      mark = googleMap.markLocation restaurant[0].get("latitude"), restaurant[0].get("longitude")
      googleMap.openInfoWindow mark, restaurant[0].toJSON(), restaurant.length)

window.Inspections = Inspections
