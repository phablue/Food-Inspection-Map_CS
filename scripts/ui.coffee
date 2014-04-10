class UI
  constructor: ->
    @url = "https://data.cityofchicago.org/resource/4ijn-s7e5.json"
    @restaurantName = null

  searchWords: ->
    @restaurantName = $(".form-control").val()

  searchResult: ->
    $.getJSON(@url, {"dba_name": @restaurantName}).done(@showResult)

  showResult: (data) ->
    $(".result").html(data.dba_name)

  searchingRestaurant: ->
    $("form").submit =>
      @searchWords()
      @searchResult()
      event.preventDefault();


window.UI = UI

ui = new UI
ui.searchingRestaurant()
