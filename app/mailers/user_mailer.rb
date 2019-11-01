# frozen_string_literal: true

class UserMailer < ApplicationMailer
  default from: 'spur@gmail.com'
  #Makin email
  def forgot_password(user, token)
    @user = user
    @token = token
    @url = reset_api_v1_user_url(@user.id, tokens: token)
    mail to: user.email, subject: 'Forgot passowrd'
  end
end
