# frozen_string_literal: true

class Api::V1::HistoryController < ApplicationController
  before_action :authenticate, only: %i[index create]

  # Methode that return user history
  def index
    history = @user.histories
    histories = []
    @user.histories.each do |history|
      histories << { place_type: history.place_type, name: history.name, date: history.created_at.to_date }
    end
    render json: histories, status: 200
  end

  # Methode to store new hsitory
  def create
    if params[:place_type].present? && params[:name].present?
      history = History.new(history_params)
      history.user = @user; history.save; message = 'History saved successfully'
    else
      message = "Fields can't be empty!"
    end
    render json: { message: message }, status: :ok
  end

  private

  def history_params # permit user params
    params.permit(:place_type, :lat, :lng, :name)
  end
end
