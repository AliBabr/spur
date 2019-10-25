class User < ApplicationRecord
  acts_as_token_authenticatable User
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
         
  has_many :histories, dependent: :destroy
  has_many :preferences, dependent: :destroy


  private
  def after_successful_token_authentication
  # Make the authentication token to be disposable - for example
  renew_authentication_token!
  end

  # Function will return false if token doesn't mtch but return nil if user not found
  def self.validate_token(id,auth_token)
    user = self.find_by_id(id)
    if user.present?
      user.authentication_token == auth_token
    end
  end
end
