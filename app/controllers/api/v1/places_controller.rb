class Api::V1::PlacesController < ApplicationController
    def index
        begin
            @client = GooglePlaces::Client.new(ENV["GOOGLE_PLACES_KEY"])
            arr = Array.new
            temp=@client.spots(-33.8670522, 151.1957362, :types => ['bars', 'restaurant'])

            # Select places on the basis of price_level
            temp.each do | item |
                arr << item if item.price_level.present? && item.price_level > 2               
            end

            # Filter data from places
            # placeslist = temp.map do |u|
            #     { :name => u.name, :lat => u.lat, :lng => u.lng, :price_level => u.price_level, :ratings => u.rating}
            # end
            
            render :json => { :message => "Success!", :data => arr.first }, :status => :ok
        rescue => exception
            render :json => { :message => "Error "+exception }, :status => :bad_request
        end
        
    end
end
