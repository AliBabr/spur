# frozen_string_literal: true

class Api::V1::NotificationsController < ApplicationController
  before_action :authenticate, only: %i[toggle_notification]

  # methode that enable disable user notification status
  def toggle_notification
    if params[:status].present?
      @user.update(notification_status: params[:status])
      if @user.errors.any?
        render json: user.errors.messages, status: 400
      else
        render json: { message: 'Notification status updated successfuly!' }, status: 200
      end
    else
      render json: { message: 'Please set status' }, status: 400
    end
  end
  rescue StandardError => e
    render json: { message: 'Error: Something went wrong... ' }, status: :bad_request
end
