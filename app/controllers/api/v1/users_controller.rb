
class Api::V1::UsersController < ApplicationController

  # Validates user and send token in response
  def sign_in
    if params[:email].blank?
      render json: {message: "Email can't be blank!"}
    else
      user = User.find_by_email(params[:email])
      if user.present? && user.valid_password?(params[:password])
        render json: user.as_json(only: [:first_name, :last_name, :email]), status: :logged_in
        response.headers["UUID"]=user.uuid
        response.headers["Authentication-Token"]=user.authentication_token
      else
        render json: {message: "No Email and Password matching that account were found"}
      end
    end
  end


  # Method which accepts credential from user and save data in db
  def sign_up
    user = User.new(user_params)
    user.uuid=SecureRandom.uuid 
    if user.save
      render json: user.as_json(only: [:first_name, :last_name, :email]), status: :created
      response.headers["UUID"]=user.uuid
      response.headers["Authentication-Token"]=user.authentication_token
    else
      render json: user.errors.messages
    end
  end

  def log_out
    user = User.find_by_uuid(request.headers['UUID'])
    if user.present?
      if User.validate_token(request.headers['UUID'],request.headers['Authentication-Token']) && user.update(authentication_token: nil)
        render json: {message: "Logged out successfuly!"}
      else
        render json: {message: "Unauthorized!"}
      end
    else
      render json: {message: "User Not Found!"}
    end
  end

  def update_account
    user = User.find_by_uuid(request.headers['UUID'])
    if user.present?
      if User.validate_token(request.headers['UUID'],request.headers['Authentication-Token'])
        user.update(user_params)
        if user.errors.any?
          render json: user.errors.messages
        else
        render json: user.as_json(only: [:first_name, :last_name, :email])
        end
      else
        render json: {message: "Unauthorized!"}
      end
    else
      render json: {message: "User Not found!"}
    end
  end

  def update_password
    binding.pry
    user = User.find_by_uuid(request.headers['UUID'])
    if user.present?
      if User.validate_token(request.headers['UUID'],request.headers['Authentication-Token'])
        if params[:current_password].present?
          if user.valid_password?(params[:current_password])
            user.update(user_params)
            if user.errors.any?
              render json: user.errors.messages
            else
              render json: user.as_json(only: [:first_name, :last_name, :email])
            end
          else
            render json: {message: "Invalid Current Password!"}
          end
        else
          render json: {message: "Password Empty!"}
        end
      else
        render json: {message: "Unauthorized!"}
      end
    else
      render json: {message: "User Not found!"}
    end
  end

  def reset
    @uuid = params[:id]
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
        render json: {message: "Please check your Email for reset password!"}
      else
        render json: {message: "Invalid Email!"}
      end
    end
  end

  def reset_password
    @uuid = params[:uuid]
    @user = User.find_by_uuid(params[:uuid])
    if params[:password] == params[:confirm_password]
      if params[:token] === @user.reset_token && @user.last.updated_at > DateTime.now-1
        @user.update(password: params[:password], password_confirmation: params[:confirm_password], reset_token: '')
        if @user.errors.any?
          render 'reset'
        end
      else
        @error = "Token is not macthing or expired"
        render 'reset'
      end
    else
      @error = "Password and confirm password should match"
      render 'reset'
    end
  end

  private

  def user_params
    params.permit(:email, :password, :first_name, :last_name)
  end
end