# app/services/GooglePlaces.rb
class Places
  def initialize(params, current_user)
    @params = params
    @user=current_user
    # Default Values
    @radius = '100'
    @price_level = '2'
    @type = 'restaurant'
  end

  def get_place
    selectPlace = []
    @price_level = @params[:price_level] if @params[:price_level].present?
    if @params[:lat].present? && @params[:lng].present?
      places=search_place
      if places.present?
        # Select places on the basis of price_level
        places.each do |place|
          selectPlace << place if place["price_level"].present? && place["price_level"] == @price_level.to_i && place["types"].include?(@type)
        end
        place=choose_place(selectPlace)
      end
    else
      return {:data => 'Longitude or Latitude missing', :message => 'Error', :status => 400}
    end
    place.present? ? {:data => place, :message => 'Success', :status => 200} : {:data => "Broaden your search criteria, there were not enough available venues", :message => "Error", :status => 404}
  end

  private
  # Search Place from Google Places api
  def search_place
    @radius = @params[:radius] if @params[:radius].present?
    @type = @params[:type] if @params[:type].present?
    if @params[:filters].present?
      places=HTTParty.get("https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=#{@params[:lat]},#{@params[:lng]}&key=#{ENV['GOOGLE_PLACES_KEY']}&name="+@params[:filters]+"&radius=#{@radius}&type=#{@type}")
    else
      places=HTTParty.get("https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=#{@params[:lat]},#{@params[:lng]}&key=#{ENV['GOOGLE_PLACES_KEY']}&radius=#{@radius}&type=#{@type}")
    end
    places["results"] 
  end

  # Choose a place From searched places
  def choose_place(places)
    userPlaceIds=@user.histories.pluck(:place_id)
    selectPlace=places.select do |place|
      !userPlaceIds.include?(place["place_id"])
    end
    randomPlace = rand(0..selectPlace.count-1)
    selectPlace.present? ? selectPlace[randomPlace] : nil
  end
end
