class Api::V1::UsersController < ApplicationController
  before_action :authenticate, only: %i[update_account update_password log_out] # callback for validating user
  before_action :forgot_validation, only: [:forgot_password]
  before_action :before_reset, only: [:reset_password]

  # Method which accept credential from user and sign in and return user data with authentication token
  def sign_in
    if params[:email].blank?
      render json: { message: "Email can't be blank!" }
    else
      user = User.find_by_email(params[:email])
      if user.present? && user.valid_password?(params[:password])
        render json: { email: user.email, first_name: user.first_name, last_name: user.last_name, 'X-SPUR-USER-ID' => user.id, 'Authentication-Token' => user.authentication_token }, status: 200
      else
        render json: { message: 'No Email and Password matching that account were found' }, status: 400
      end
    end
  rescue StandardError => e # rescue if any exception occurr
    render json: { message: 'Error: Something went wrong... ' }, status: 400
  end

  # Method which accepts parameters from user and save data in db
  def sign_up
    user = User.new(user_params); user.id = SecureRandom.uuid # genrating secure uuid token
    if user.save
      render json: { email: user.email, first_name: user.first_name, last_name: user.last_name, 'X-SPUR-USER-ID' => user.id, 'Authentication-Token' => user.authentication_token }, status: 200
    else
      render json: user.errors.messages, status: 400
    end
  rescue StandardError => e # rescue if any exception occurr
    render json: { message: 'Error: Something went wrong... ' }, status: 400
  end

  # Method that expire user session
  def log_out
    @user.update(authentication_token: nil)
    render json: { message: 'Logged out successfuly!' }, status: 200
  rescue StandardError => e
    render json: { message: 'Error: Something went wrong... ' }, status: :bad_request
  end

  # Method take parameters and update user account
  def update_account
    @user.update(user_params)
    if @user.errors.any?
      render json: @user.errors.messages, status: 400
    else
      render json: @user.as_json(only: %i[first_name last_name email]), status: 200
    end
  rescue StandardError => e
    render json: { message: 'Error: Something went wrong... ' }, status: :bad_request
  end

  # Method take current password and new password and update password
  def update_password
    if params[:current_password].present? && @user.valid_password?(params[:current_password])
      @user.update(password: params[:new_password])
      if @user.errors.any?
        render json: @user.errors.messages, status: 400
      else
        render json: { message: 'Password updated successfully!' }, status: 200
      end
    else
      render json: { message: 'Current Password is not present or invalid!' }, status: 400
    end
  rescue StandardError => e # rescue if any exception occurr
    render json: { message: 'Error: Something went wrong... ' }, status: :bad_request
  end

  # Method that render reset password form
  def reset
    @token = params[:tokens]
    @id = params[:id]
  end

  # Method that send email while user forgot password
  def forgot_password
    UserMailer.forgot_password(@user, @token).deliver
    @user.update(reset_token: @token)
    render json: { message: 'Please check your Email for reset password!' }, status: 200
  rescue StandardError => e
    render json: { message: 'Error: Something went wrong... ' }, status: :bad_request
  end

  # Method that take new password and confirm password and reset user password
  def reset_password
    if (params[:token] === @user.reset_token) && (@user.updated_at > DateTime.now - 1)
      @user.update(password: params[:password], password_confirmation: params[:confirm_password], reset_token: '')
      render 'reset' if @user.errors.any?
    else
      @error = 'Token is expired'; render 'reset'
    end
  rescue StandardError => e
    render json: { message: 'Error: Something went wrong... ' }, status: :bad_request
  end

  private

  def user_params # permit user params
    params.permit(:email, :password, :first_name, :last_name)
  end

  # Helper method for forgot password method
  def forgot_validation
    if params[:email].blank?
      render json: { message: "Email can't be blank!" }, status: 400
    else
      @user = User.where(email: params[:email]).first
      if @user.present?
        o = [('a'..'z'), ('A'..'Z')].map(&:to_a).flatten; @token = (0...15).map { o[rand(o.length)] }.join
      else
        render json: { message: 'Invalid Email!' }, status: 400
      end
    end
  end

  # Helper method for reset password method
  def before_reset
    @id = params[:id]; @token = params[:token]; @user = User.find_by_id(params[:id])
    if params[:password] == params[:confirm_password]
      return true
    else
      @error = 'Password and confirm password should match'
      render 'reset'
    end
  end
end
