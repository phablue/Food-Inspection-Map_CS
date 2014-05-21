class Inspections extends Backbone.Collection
  initialize: ->
    @resourceURL = "https://data.cityofchicago.org/resource/4ijn-s7e5.json"

  url: ->
    @resourceURL

  urlByName: (restaurantName) ->
    unless _.isUndefined(restaurantName)
      return "#{@resourceURL}?dba_name=#{restaurantName}"
    @resourceURL

  allRestaurantsHasViolations: ->
    this.filter((restaurant) -> restaurant.get("violations"))

  restaurantHasViolationsByName: (restaurantName) ->
    @allRestaurantsHasViolations().filter((restaurant) -> restaurant.get("dba_name") == restaurantName)

  namesOfRestaurantsViolations: ->
    restaurants = []
    @allRestaurantsHasViolations().forEach((restaurant) -> restaurants.push(restaurant.get("dba_name")))
    _.uniq(restaurants);

window.Inspections = Inspections
