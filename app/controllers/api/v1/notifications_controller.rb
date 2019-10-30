class Api::V1::NotificationsController < ApplicationController

  def toggle_notification
    user = User.find_by_id(request.headers['X-SPUR-USER-ID'])
    if user.present?
      if User.validate_token(request.headers['X-SPUR-USER-ID'],request.headers['Authentication-Token'])
        if params[:status].present?
          user.update(notification_status: params[:status])
          render json: {message: "Notification status updated successfuly!"}, :status => 200
        else
          render json: {message: "Please set status"}, :status => 400
        end
      else
        render json: {message: "Unauthorized!"}, :status => 401
      end
    else
      render json: {message: "User Not Found!"}, :status => 404
    end
  end

end