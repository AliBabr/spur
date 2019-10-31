class Api::V1::PlacesController < ApplicationController
    before_action :authenticate, only: %i[index]
    before_action :save_preference

    def index
        begin
            selectPlace=Places.new(params).get_place 
            render :json => { :message => "Success", :data => selectPlace }, :status => :ok
        rescue => exception
            render :json => { :message => "Error: Something went wrong... " }, :status => :bad_request
        end    
    end

    def save_preference
        preference=Preference.new()
        if params[:filters].present?
            filters = params[:filters].try(:values)
            preference.filters=filters
        end
        if params[:price_level].present?
            preference.price_level=params[:price_level].to_i
        end
        preference.user=@user
        preference.save 
    end
end
  