
class Api::V1::UsersController < ApplicationController

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

  def log_out
    user = User.find(params[:id])
    if user.present?
      if validate_token() && User.find(params[:id]).update(authentication_token: nil)
        render json: {message: "log out successfuly!"}
      else
        render json: {message: "unauthorized!"}
      end
    else
      render json: {message: "User Not found please give valid id"}
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
        render json: user.as_json(only: [:id, :first_name, :last_name, :email])
        end
      else
        render json: {message: "unauthorized!"}
      end
    else
      render json: {message: "User Not found please give valid id"}
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
              render json: user.as_json(only: [:id, :first_name, :last_name, :email])
            end
          else
            render json: {message: "current_password is not matching!"}
          end
        else
          render json: {message: "please provide current password!"}
        end
      else
        render json: {message: "unauthorized!"}
      end
    else
      render json: {message: "User Not found please give valid id"}
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
    if user.present?
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
    else
      render json: {message: "User Not found please give valid id"}
    end
  end

  def reset_password
    user = User.find(params[:id])
    if user.present?
      user = User.find(params[:id])
      if validate_token()
        if params[:confirm_password].present?
          user.update(user_params.merge({password_confirmation: params[:confirm_password]}))
          if user.errors.any?
            render json: user.errors.messages
          else
            render json: user.as_json(only: [:id, :first_name, :last_name, :email])
          end
        else
          render json: {message: "confirm password is not present"}
        end
      else
        render json: {message: "unauthorized!"}
      end
    else
      render json: {message: "User Not found please give valid id"}
    end
  end

  private

  def validate_token
    User.find(params[:id]).authentication_token == params[:authentication_token]
  end

  def user_params
    params.permit(:email, :password, :first_name, :last_name)
  end

end