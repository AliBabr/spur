class Api::V1::PlacesController < ApplicationController
  before_action :authenticate, only: %i[index]
  before_action :save_preference

  def index
    response = Places.new(params, @user).get_place
    render json: { message: response[:message], data: response[:data] }, status: response[:status]
  rescue StandardError => e
    render json: { message: "Error: Something went wrong..." }, status: 400
  end

  def save_preference
    preference = Preference.new
    if params[:choices].present?
      choices = params[:choicess]
      preference.filters = choices
    end
    if params[:price_level].present?
      preference.price_level = params[:price_level].to_i
    end
    preference.user = @user
    preference.save
  end
end
