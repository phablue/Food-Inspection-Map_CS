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

window.Inspections = Inspections
