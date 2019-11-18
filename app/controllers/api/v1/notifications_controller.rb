# frozen_string_literal: true

class Api::V1::NotificationsController < ApplicationController
  before_action :authenticate, only: %i[toggle_notification]

  # methode that enable disable user notification status
  def toggle_notification
    @user.update(notification_params)
    if @user.errors.any?
      render json: user.errors.messages, status: 400
    else
      render json: { message: 'Notifications are Successfully Updated!' }, status: 200
    end
  rescue StandardError => e
    render json: { message: 'Error: Something went wrong... ' }, status: :bad_request
  end

  private

  def notification_params
    params.permit(:arrival_notification, :pickup_notification)
  end
end
