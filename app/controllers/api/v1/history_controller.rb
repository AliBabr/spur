# frozen_string_literal: true

class Api::V1::HistoryController < ApplicationController
  before_action :authenticate, only: %i[index new]

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
  def new
    if params[:type].present? && params[:lat].present? && params[:lng].present? && params[:place_name].present?
      history = History.new(place_type: params[:type], lat: params[:lat], lng: params[:lng], name: params[:place_name])
      history.user = @user
      history.save
      message = 'History saved successfully'
    else
      message = "Fields can't be empty!"
    end
    render json: { message: message }, status: :ok
  end
end
