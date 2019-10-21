
class Api::V1::UsersController < ApplicationController

  # Validates user and send token in response
  def sign_in
    if params[:email].blank?
      render json: {message: "Email can't be blank!"}
    else
      user = User.find_by_email(params[:email])
      if user.present? && user.valid_password?(params[:password])
        render json: user.as_json(only: [:first_name, :last_name, :email]), status: :logged_in
        response.headers["uuid"]=user.uuid
        response.headers["authentication_token"]=user.authentication_token
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
      response.headers["uuid"]=user.uuid
      response.headers["authentication-token"]=user.authentication_token
    else
      render json: user.errors.messages
    end
  end

  def log_out
    user = User.find_by_uuid(params[:uuid])
    if user.present?
      if User.validate_token(params[:uuid],params[:authentication_token]) && user.update(authentication_token: nil)
        render json: {message: "Logged out successfuly!"}
      else
        render json: {message: "Unauthorized!"}
      end
    else
      render json: {message: "User Not found!"}
    end
  end

  def update
    user = User.find(params[:id])
    if user.present?
      if validate_token()
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
    user = User.find(params[:id])
    if user.present?
      user = User.find(params[:id])
      if validate_token()
        if params[:current_password].present?
          if user.valid_password?(params[:current_password])
            user.update(user_params)
            if user.errors.any?
              render json: user.errors.messages
            else
              render json: user.as_json(only: [:first_name, :last_name, :email])
            end
          else
            render json: {message: "Invalid Password!"}
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
        render json: {reset_password_token: token, id: user.id}
      else
        render json: {message: "Invalid Email!"}
      end
    end
  end

  def reset_password
    @uuid = params[:uuid]
    @user = User.find(params[:uuid])
    if params[:password] == params[:confirm_password]
      if params[:toekn] == @user.reset_token
        @user.update(password: params[password], password_confirmation: params[:confirm_password], reset_token: '')
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

  # def validate_token
  #   User.find(params[:id]).authentication_token == params[:authentication_token]
  # end

  def user_params
    params.permit(:email, :password, :first_name, :last_name)
  end

end