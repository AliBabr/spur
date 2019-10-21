
class Api::V1::UsersController < ApplicationController

  def sign_in
    if params[:email].blank?
      render json: {message: "Email can't be blank!"}
    else
      user = User.where(email: params[:email]).first
      if user.present?
        if user.valid_password?(params[:password])
          render json: user.as_json(only: [:first_name, :last_name, :email, :authentication_token]), stauts: :loged_in
          response.headers['authentication_token'] = user.authentication_token
          response.headers['UUID'] = user.id
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
      render json: user.as_json(only: [:first_name, :last_name, :email]), stauts: :loged_up
      response.headers['authentication_token'] = user.authentication_token
      response.headers['UUID'] = user.id
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

  def validate_token
    User.find(params[:id]).authentication_token == params[:authentication_token]
  end

  def user_params
    params.permit(:email, :password, :first_name, :last_name)
  end

end