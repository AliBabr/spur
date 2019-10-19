
class Api::V1::UsersController < ApplicationController
  # before_action :authenticate_user!
  # respond_to :json
  # skip_before_filter :verify_authenticity_token

  def sign_in
    if params[:email].blank?
      render json: "Email can't be blank!"
    else
      user = User.where(email: params[:email]).first
      if user.present?
        if user.valid_password?(params[:password])
          render json: user.as_json(only: [:id, :first_name, :last_name, :email, :authentication_token]), stauts: :loged_in
        else
          render json: "Invalid password"
        end
      else
        render json: "Invalid Email"
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
      render json: "log out successfuly"
    else
      render json: "unauthorized"
    end
  end

  def update
    if validate_token()
      user = User.find(params[:id])
      user.update(user_params)
      if user.errors.any?
        render json: user.errors.messages
      else
      render json: user.as_json(only: [:id, :first_name, :last_name, :email, :authentication_token])
      end
    else
      render json: "unauthorized"
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
            render json: user.as_json(only: [:id, :first_name, :last_name, :email, :authentication_token])
          end
        else
          render json: 'current_password is not matching'
        end
      else
        user.update(user_params)
        if user.errors.any?
          render json: user.errors.messages
        else
          render json: user.as_json(only: [:id, :first_name, :last_name, :email, :authentication_token])
        end
      end
    else
      render json: "unauthorized"
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
