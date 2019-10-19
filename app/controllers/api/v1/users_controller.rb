
class Api::V1::UsersController < ApplicationController
  # before_action :authenticate_user!
  # respond_to :json
  # skip_before_filter :verify_authenticity_token

  def sign_in
    user = User.where(email: params[:email]).first
    if user&.valid_password?(params[:password])
      render json: user.as_json(only: [:id, :first_name, :last_name, :email, :authentication_token]), stauts: :loged_in
    else
      head(:unauthorized)
    end
  end

  def sign_up
    user = User.new(first_name: params[:first_name], last_name: params[:last_name], email: params[:email], password: params[:password], password_confirmation: params[:confirm_password])
    if user.save
      render json: user.as_json(only: [:id, :first_name, :last_name, :email, :authentication_token]), stauts: :created
    else
      head(:unauthorized)
    end
  end

  def log_out
    if validate_token() && User.find(params[:user_id]).update(authentication_token: nil)
      render json: "log out successfuly"
    else
      head(:unauthorized)
    end

  end

  private
  def validate_token
    User.find(params[:user_id]).authentication_token == params[:authentication_token]
  end


end 
