# frozen_string_literal: true
class Api::V1::NotificationsController < ApplicationController
  before_action :authenticate, only: %i[toggle_notification]
  require 'fcm'

  def send_notification
    fcm = FCM.new("AAAA3bL1Yq8:APA91bF_JJQKHH9m7-ZqpFMikq59kBFyNCBrov4Kdg4R2wK8Bho0iAfDdi389o8mlbgXnsCYBjumuD-w9XSAJwqm4m4p-PrFLfT7wRdi80E0stOgVGyuu7pqbP5ZjvXp-ism_0LSSPkC")
    # you can set option parameters in here
    #  - all options are pass to HTTParty method arguments
    #  - ref: https://github.com/jnunemaker/httparty/blob/master/lib/httparty.rb#L29-L60
    #  fcm = FCM.new("my_server_key", timeout: 3)

    registration_ids= ["cD28hYQkI0U:APA91bElWoqZTFgckEV1HKN4PbWrMqRlUnTT-A7XHDvFkCjPRfpPSqfcnH8rALLm5qaJeoMN_nYzqKslIJDBZ9jZOUu-gKWbewBxm4h_h5LJB4j-fc0oGupq4dcoWuSCvwZZtlJfqFiM", "123455"] # an array of one or more client registration tokens

    # See https://firebase.google.com/docs/reference/fcm/rest/v1/projects.messages for all available options.
    options = { "notification": {
                  "title": "Portugal vs. Denmark",
                  "body": "5 to 1"
              }
    }
    response = fcm.send(registration_ids, options)
    render json: {responses: response}
  end
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
