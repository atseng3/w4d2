require 'addressable/uri'
require 'rest-client'
require 'json'
require 'nokogiri'

class IceCreamFinder

# Figure out our location using Geocoding API
  def run
    puts "What's your location?"
    location = gets.chomp
    geocoding_results = RestClient.get(build_geocoding_url(location))
    parsed_geo = JSON.parse(geocoding_results)
    coordinates = parsed_geo["results"][0]["geometry"]["location"]

    place_results = RestClient.get(build_places_url(coordinates["lat"], coordinates["lng"]))
    parsed_places = JSON.parse(place_results)["results"]
    ice_cream_stores = []
    parsed_places.each do |place|
      ice_cream_stores << place["name"]
    end
    puts "Select an ice cream store"
    ice_cream_stores.each_with_index do |store_name, index|
      puts "#{index+1}. #{store_name}"
    end
    store_selection = (gets.chomp.to_i)-1


    destination_coord = parsed_places[store_selection]["geometry"]["location"]
    direction_results = RestClient.get(build_directions_url(location, destination_coord))
    parsed_directions = JSON.parse(direction_results)


    parsed_directions["routes"][0]["legs"][0]["steps"].each do |step|
      puts Nokogiri::HTML(step["html_instructions"]).text
      puts "\n"
    end






  end

  def build_geocoding_url(location)
    Addressable::URI.new(
    :scheme => "https",
    :host => "maps.googleapis.com",
    :path => "maps/api/geocode/json",
    :query_values => {:address => location,
                      :sensor => "false"}
    ).to_s
  end

  def build_places_url(lat, long)
    Addressable::URI.new(
    :scheme => "https",
    :host => "maps.googleapis.com",
    :path => "maps/api/place/nearbysearch/json",
    :query_values => {
                  :location => "#{lat},#{long}",
                  :radius => 500,
                  :sensor => "false",
                  :keyword => "ice cream",
                  :key => "AIzaSyB69K1xzM_oMvTf7SvD7_Q079tyvFIaEiM"
                }
    ).to_s
  end

  def build_directions_url(origin, dest)
    Addressable::URI.new(
    :scheme => "https",
    :host => "maps.googleapis.com",
    :path => "maps/api/directions/json",
    :query_values => {
                  :origin => "#{origin}",
                  :destination => "#{dest['lat']},#{dest['lng']}",
                  :sensor => "false"
                }
    ).to_s

  end

end

# Using Places API search for ice cream with our location.

# Pick one ice cream location, use Directions API to get directions from our location.

a = IceCreamFinder.new
a.run