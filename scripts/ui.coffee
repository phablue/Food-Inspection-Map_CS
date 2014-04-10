class UI
  constructor: ->
    @url = "https://data.cityofchicago.org/resource/4ijn-s7e5.json?$limit=25&$offset=0"
    @restaurantName = null

  searchRestaurant: ->
    @restaurantName = encodeURIComponent $(".form-control").val()

  getData: ->
    $.getJSON(@url, {"dba_name": @restaurantName}).done((data) ->
      $(".result").text(data.dba_name))

window.UI = UI
