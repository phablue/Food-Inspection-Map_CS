class Inspections extends Backbone.Collection
  initialize: ->
    @resourceURL = "https://data.cityofchicago.org/resource/4ijn-s7e5.json"

  url: ->
    @resourceURL

  urlByName: (restaurntName) ->
    unless _.isUndefined(restaurntName)
      return "#{@resourceURL}?dba_name=#{restaurntName}"
    @resourceURL

  allRestaurantsHasViolations: ->
    this.filter((restaurant) -> restaurant.get("violations"))

  restaurantHasViolationsByName: (i) ->
    _this = this
    @allRestaurantsHasViolations().filter((restaurant) -> restaurant.get("dba_name") == _this.namesOfRestaurantsViolations()[i])

  namesOfRestaurantsViolations: ->
    restaurants = []
    @allRestaurantsHasViolations().forEach((restaurant) -> restaurants.push(restaurant.get("dba_name")))
    _.uniq(restaurants);

window.Inspections = Inspections
