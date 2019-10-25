class Api::V1::PlacesController < ApplicationController
  def index
    if User.validate_token(request.headers["UUID"],request.headers["Authentication-Token"])!=false
      user=User.find_by_id(request.headers["UUID"])
        if user.present?
            begin
                @client = GooglePlaces::Client.new(ENV["GOOGLE_PLACES_KEY"])
                
                # Initiliazing array to filter data from places below
                selectPlace = Array.new
                #----------------------- save preferences --------------------
                preference=Preference.new()
                if params[:filters].present?
                    filters = params[:filters].try(:values)
                    preference.filters=filters
                end
                if params[:price_level].present?
                    preference.price_level=params[:price_level].to_i
                end
                preference.user=user
                preference.save 
                #------------------ Ending Save preferences ------------------------ 
                
                places=@client.spots(params[:lat], params[:lng], :radius => params[:radius], :types => params[:type])
                # Select places on the basis of price_level
                places.each do | item |
                    selectPlace << item if item.price_level.present? && item.price_level == params[:price_level].to_i               
                end

                # Filter data from places
                # placeslist = places.map do |u|
                #     { :name => u.name, :lat => u.lat, :lng => u.lng, :price_level => u.price_level, :ratings => u.rating}
                # end
    
                #---------------- Begining Code to save history --------------------
                history=History.new(place_type: params[:type], lat:selectPlace.first.lat, lng:selectPlace.first.lng, google_place_id:selectPlace.first.place_id)
                history.user=user
                history.save
                #------------------- Ending Code for history -------------------------
                
                render :json => { :message => "Success", :data => selectPlace.first }, :status => :ok
            rescue => exception
                render :json => { :message => "Error: Something went wrong #{exception}" }, :status => :bad_request
            end
        else
            render :json =>{ :message => "User not found!"}, :status => :not_found
        end
    else
        render :json =>{ :message => "Unauthorized!"}, :status => :Unauthorized
    end     
  end
end
