class UI
  constructor: ->
    @url = "https://data.cityofchicago.org/resource/4ijn-s7e5.json?$limit=25&$offset=0"
    @restaurantName = null

  searchRestaurant: ->
    @restaurantName = encodeURIComponent $(".form-control").val()

  getData: ->


window.UI = UI
