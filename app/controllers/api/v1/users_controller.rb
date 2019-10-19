
class Api::V1::UsersController < ApplicationController
  # before_action :authenticate_user!
  # respond_to :json
  # skip_before_filter :verify_authenticity_token

  def sign_in
    if params[:email].blank?
      render json: {message: "Email can't be blank!"}
    else
      user = User.where(email: params[:email]).first
      if user.present?
        if user.valid_password?(params[:password])
          render json: user.as_json(only: [:id, :first_name, :last_name, :email, :authentication_token]), stauts: :loged_in
        else
          render json: {message: "Invalid password!"}
        end
      else
        render json: {message: "Invalid Email!"}
      end
    end
  end

  def sign_up
    user = User.new(user_params)
    if user.save
      render json: user.as_json(only: [:id, :first_name, :last_name, :email, :authentication_token]), stauts: :created
    else
      render json: user.errors.messages
    end
  end

  def index
    user = User.all
    render json: user
  end

  def log_out
    if validate_token() && User.find(params[:user_id]).update(authentication_token: nil)
      render json: {message: "log out successfuly!"}
    else
      render json: {message: "unauthorized!"}
    end
  end

  def update
    if validate_token()
      user = User.find(params[:id])
      user.update(user_params)
      if user.errors.any?
        render json: user.errors.messages
      else
      render json: user.as_json(only: [:id, :first_name, :last_name, :email])
      end
    else
      render json: {message: "unauthorized!"}
    end
  end

  def update_password
    user = User.find(params[:id])
    if validate_token()
      if params[:current_password].present?
        if user.valid_password?(params[:current_password])
          user.update(user_params)
          if user.errors.any?
            render json: user.errors.messages
          else
            render json: user.as_json(only: [:id, :first_name, :last_name, :email])
          end
        else
          render json: {message: "current_password is not matching!"}
        end
      else
        user.update(user_params)
        if user.errors.any?
          render json: user.errors.messages
        else
          render json: user.as_json(only: [:id, :first_name, :last_name, :email])
        end
      end
    else
      render json: {message: "unauthorized!"}
    end
  end


  def forgot_password
    if params[:email].blank?
      render json: {message: "Email can't be blank!"}
    else
      user = User.where(email: params[:email]).first
      if user.present?
        o = [('a'..'z'), ('A'..'Z')].map(&:to_a).flatten
        token = (0...15).map { o[rand(o.length)] }.join
        UserMailer.forgot_password(user, token).deliver
        user.update(reset_token: token)
        render json: {reset_password_token: token, id: user.id}
      else
        render json: {message: "Invalid Email!"}
      end
    end
  end

  def authenticate_reset_password_token
    user = User.find(params[:id])
    if params[:reset_password_token].present?
      if params[:reset_password_token] == user.reset_token
        render json: user.as_json(only: [:id, :authentication_token])
      else
        render json: {message: "Reset password token is not matching!"}
      end
    else
      render json: {message: "Please provide reset password token!"}
    end
  end

  private

  def validate_token
    User.find(params[:id]).authentication_token == params[:authentication_token]
  end

  def user_params
    params.permit(:email, :password, :password_confirmation, :first_name, :last_name)
  end

end