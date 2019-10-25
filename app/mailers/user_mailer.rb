class UserMailer < ApplicationMailer

  default from: "spur@gmail.com"
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.forgot_password.subject
  #
  def forgot_password(user, token)
    @user = user
    @token = token
    @url = reset_api_v1_user_url(@user.uuid, tokens: token)
    # @token = (0...50).map { ('a'..'z').to_a[rand(26)] }.join
    mail to: user.email,  subject: "Forgot passowrd"
  end
end
