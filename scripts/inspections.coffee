class Inspections extends Backbone.Collection
  initialize: (options) ->
    @ui = options.ui
    @google = options.google
    @offset = 0
    @allRestaurants = new Backbone.Collection
    @resourceURL = "https://data.cityofchicago.org/resource/4ijn-s7e5.json?$where=violations IS NOT NULL AND inspection_date >= '2014-01-01'"

  url: ->
    @urlConfig()

  urlConfig: ->
    if !_.isEmpty(@ui.searchWords())
      return "#{@resourceURL}&$q=#{encodeURIComponent @ui.searchWords()}"
    else if !_.isNull(@ui.restaurantID)
      return "#{@resourceURL}&license_=#{@ui.restaurantID}"
    "#{@resourceURL}&$offset=#{@offset}"

  changeOffSet: ->
    @offset += 1000

  searchInURL: (words) ->
    @url().search(words)

  getAllRestaurants: (def) ->
    @fetch
      success: =>
        @allRestaurants.add(@models)
        @changeOffSet()
        if @length < 1000
          return def.resolve(@allRestaurants)
        @getAllRestaurants()

  displayAllRestaurantsOnGoogleMap: ->
    def = $.deferred()
    def.done

  filterByKeyWordsFor: ->
    keyWords = new RegExp("#{@ui.searchWords()}", "gi")
    @filter((restaurant) -> restaurant.get("dba_name").match(keyWords))

  restaurantsFilterBy: (restaurantID) ->
    @filterByKeyWordsFor().filter((restaurant) -> restaurant.get("license_") == restaurantID)

  licenseIDsOfRestaurants: ->
    restaurants = new Backbone.Collection(@filterByKeyWordsFor())
    _.uniq(restaurants.pluck("license_"))

  restaurantsOnGoogleMapBy: (restaurantsID) ->
    googleMap = new GoogleMap(@google)
    _.each(restaurantsID, (restaurantID) =>
      restaurant = @restaurantsFilterBy(restaurantID)
      @settingForGoogleMap(googleMap, restaurant))

  settingForGoogleMap: (googleMap, data) ->
    mark = googleMap.markLocation data[0].get("latitude"), data[0].get("longitude")
    googleMap.openInfoWindow mark, data[0].toJSON(), data.length

window.Inspections = Inspections
