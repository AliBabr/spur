class Api::V1::PlacesController < ApplicationController
    def index
      if User.validate_token(request.headers['X-SPUR-USER-ID'],request.headers["Authentication-Token"])!=false
        user=User.find_by_id(request.headers['X-SPUR-USER-ID'])
          if user.present?
              radius = "100"
              type= 'restaurant'
              price_level="2"
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
                  radius = params[:radius] if params[:radius].present?
                  type = params[:type] if params[:type].present?
                  price_level = params[:price_level] if params[:price_level].present?
                  
                  if params[:lat].present? && params[:lng].present?
                    if params[:filters].present?
                        places=@client.spots(params[:lat], params[:lng], :radius => radius, :type=>type, :name=> params[:filters].values)
                    else
                        places=@client.spots(params[:lat], params[:lng], :radius => radius, :type=>type)
                    end
 
                    # Select places on the basis of price_level
                    places.each do | item |
                        selectPlace << item if item.price_level.present? && item.price_level == price_level.to_i               
                    end
                  else
                      return render :json => { :message => "Longitude or Latitude missing" }, :status => :bad_request
                  end
                  #---------------- Begining Code to save history --------------------
                  if selectPlace.present?
                      history=History.new(place_type: type, lat:selectPlace.first.lat, lng:selectPlace.first.lng, google_place_id:selectPlace.first.place_id)
                      history.user=user
                      history.save
                  else
                      return render :json => {:message=>"no data found" }, :status => :ok
                  end
                  #------------------- Ending Code for history -------------------------
                  
                  render :json => { :message => "Success", :data => selectPlace.first }, :status => :ok
              rescue => exception
                  render :json => { :message => "Error: Something went wrong" }, :status => :bad_request
              end
          else
              render :json =>{ :message => "User not found!"}, :status => :not_found
          end
      else
          render :json =>{ :message => "Unauthorized!"}, :status => :Unauthorized
      end     
    end
  end
  