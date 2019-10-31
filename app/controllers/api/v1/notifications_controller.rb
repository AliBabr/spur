class Api::V1::NotificationsController < ApplicationController
  before_action :authenticate, only: %i[toggle_notification]

  #methode that enable disable user notification status
  def toggle_notification
    if params[:status].present?
      @user.update(notification_status: params[:status])
      render json: {message: "Notification status updated successfuly!"}, :status => 200
    else
      render json: {message: "Please set status"}, :status => 400
    end
  end

end