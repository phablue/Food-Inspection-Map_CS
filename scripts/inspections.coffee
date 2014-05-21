class Inspections extends Backbone.Collection
  initialize: (@google) ->
    @resourceURL = "https://data.cityofchicago.org/resource/4ijn-s7e5.json?$order=inspection_date%20ASC"

  url: ->
    @resourceURL

  urlByName: (restaurantName) ->
    unless _.isUndefined(restaurantName)
      return "#{@resourceURL}?dba_name=#{restaurantName}"
    @resourceURL

  allRestaurantsHasViolations: ->
    this.filter((restaurant) -> restaurant.get("violations"))

  restaurantHasViolationsByAddress: (restaurantAddress) ->
    @allRestaurantsHasViolations().filter((restaurant) -> restaurant.get("address") == restaurantAddress)

  addressOfRestaurantsViolations: ->
    address = []
    @allRestaurantsHasViolations().forEach((restaurant) -> address.push(restaurant.get("address")))
    _.uniq(address);

window.Inspections = Inspections
