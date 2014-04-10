class UI
  constructor: ->
    @url = "https://data.cityofchicago.org/resource/4ijn-s7e5.json"
    @restaurantName = null

  searchWords: ->
    @restaurantName = $(".form-control").val()

  searchResult: ->
    $.getJSON(@url, {"dba_name": @restaurantName}).done(@showResult)

  showResult: (data) =>
    i = 0
    $(".sub-header").text @restaurantName
    while i < data.length
      $("h3").html "<label>Address : </label>&nbsp" + data[0].address
      $("tbody").append "<tr><td>" + (i+1) + "</td><td>" + data[i].inspection_type + "</td><td>" + data[i].inspection_date + "</td><td>" + data[i].risk + "</td><td>" + data[i].results + "</td></tr>"
      i++

  searchingRestaurant: ->
    $("form").submit =>
      @searchWords()
      @searchResult()
      event.preventDefault();


window.UI = UI

ui = new UI
ui.searchingRestaurant()
