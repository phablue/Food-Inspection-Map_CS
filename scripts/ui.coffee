class UI
  constructor: ->
    @url = "https://data.cityofchicago.org/resource/4ijn-s7e5.json?$limit=25&$offset=0"
    @restaurantName = null

  searchWords: ->
    @restaurantName = encodeURIComponent $(".form-control").val()

  searchResult: ->
    $.getJSON(@url, {"dba_name": @restaurantName}).done(@showResult)

  showResult: (data)->
    $(".result").html(data.dba_name)

  searchingRestaurant: ->
    $("form").submit =>
      @searchWords()
      @searchResult()
      event.preventDefault();

window.UI = UI
