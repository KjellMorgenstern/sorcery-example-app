class LoginMailer < ActionMailer::Base
  def send_email(user, url)
    @user = user
    @url  = url

    mail to: @user.email, subject: 'Sign in into sorcery example app'
  end
end
