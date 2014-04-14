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
      $(".result").before '<br><br><p class="bg-danger">No results for &nbsp"' + @restaurantName + '"</p>'
    else if !@checkHasViolations(data)
      @showElement ".result"
      i = 0
      $(".page-header").text @restaurantName
      $(".page-header").append "<small>&nbsp&nbsp(" + data[0].address + "Chicago)</small>"
      while i < data.length
        $("tbody").append "<tr><td>" + (i+1) + "</td><td>" + data[i].inspection_type + "</td><td>" +
                          data[i].inspection_date + "</td><td>" + data[i].risk + "</td><td>" + data[i].results +
                          "</td><td>" +  data[i].violations + "</td></tr>"
        i++
        # how to json data edit? '|' replace to "\n"
        # pass getjson  searchwords include name

  searchingRestaurant: ->
    @hideElement ".result"
    $("form").submit =>
      @resetSearchResult()
      @searchWords()
      @searchResult()
      event.preventDefault()

  resetSearchResult: ->
    $(".title, tbody").empty()
    $(".bg-danger, br").remove();
    $(".title").html '<h1 class = "page-header"><small></small></h1>'

  hideElement: (element) ->
    $(element).hide()

  showElement: (element) ->
    $(element).show()

  checkHasViolations: (data) ->
    true if _.isNull(@howManyViolations(data))
    false

  howManyViolations: (data) ->
    violations = 0
    i = 0
    while i < data.length
      if !_.isUndefined(data[i].violations)
        violations++
      i++

window.UI = UI
