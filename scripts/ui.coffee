class UI
  constructor: ->
    @url = "https://data.cityofchicago.org/resource/4ijn-s7e5.json"
    @restaurantName = null

  searchWords: ->
    @restaurantName = $(".form-control").val()

  searchResult: ->
    $.getJSON(@url, {"dba_name": @restaurantName}).done @showResult

  showResult: (data) =>
    if _.isEmpty(data)
      $(".title").prepend '<p class="bg-danger">No results for &nbsp"' + @restaurantName + '"</p>'
    else
      i = 0
      $(".sub-header").text @restaurantName
      while i < data.length
        $("h3").html "<label>Address : </label>&nbsp" + data[0].address
        $("tbody").append "<tr><td>" + (i+1) + "</td><td>" + data[i].inspection_type + "</td><td>" +
                          data[i].inspection_date + "</td><td>" + data[i].risk + "</td><td>" + data[i].results +
                          "</td><td>" +  data[i].violations + "</td></tr>"
        i++
        # how to json data edit? '|' replace to "\n"
        # pass getjson  searchwords include name

  searchingRestaurant: ->
    @hidetable()
    $("form").submit =>
      @resetSearchResult()
      @searchWords()
      @searchResult()
      event.preventDefault()

  resetSearchResult: ->
    $("tbody").empty()
    $(".title").html '<h2 class = "sub-header"></h2><h3></h3><br>'

  hidetable: ->
    $("thead").hide()

window.UI = UI
