class User < ApplicationRecord
  acts_as_token_authenticatable User
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  private
  def after_successful_token_authentication
  # Make the authentication token to be disposable - for example
  renew_authentication_token!
  end
end
