# app/services/GooglePlaces.rb
class Places

  def initialize(params)
    @params=params
    # Default Values
    @radius="100"
    @price_level="2"
    @type="restaurant"
  end

  def get_place
    # Default Values
    selectPlace = Array.new
    @price_level = @params[:price_level] if @params[:price_level].present?

    @client = GooglePlaces::Client.new(ENV["GOOGLE_PLACES_KEY"])
    if @params[:lat].present? && @params[:lng].present?
      search_place()
      # Select places on the basis of price_level
      @places.each do | item |
        selectPlace << item if item.price_level.present? && item.price_level == @price_level.to_i               
      end
    else
      return "Longitude or Latitude missing"
    end
    randomPlace=rand(0..selectPlace.count)
    selectPlace.present? ? selectPlace[randomPlace] : nil
  end

  def search_place
    @radius = @params[:radius] if @params[:radius].present?
    @type = @params[:type] if @params[:type].present?

    if @params[:filters].present?
        @places=@client.spots(@params[:lat], @params[:lng], :radius => @radius, :type=>@type, :name=> @params[:filters].values)
    else
        @places=@client.spots(@params[:lat], @params[:lng], :radius => @radius, :type=>@type)
    end
  end 
end