class Api::V1::PlacesController < ApplicationController
    def index
        begin
            @client = GooglePlaces::Client.new('AIzaSyD-2KnDs0lN_0Z293JcYo9pDFF280_819k')
            temp=@client.spots(-33.8670522, 151.1957362, :types => ['restaurant','bar'])
            temp1=@client.predictions_by_input('San F',lat: 0.0,lng: 0.0,radius: 20000000,types: 'geocode')
            binding.pry
        rescue => exception
            binding.pry
        end
        
        respond_to do |format|
            msg = { :status => "ok", :message => "Success!" }
            format.json  { render :json => msg } # don't do msg.to_json
          end
    end
end
