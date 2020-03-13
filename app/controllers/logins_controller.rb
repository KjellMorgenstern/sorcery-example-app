class LoginsController < ApplicationController
  skip_before_action :require_login, only: [:new, :create]

  def new
    @user = User.new
  end

  def create
    user = User.find_or_create_by!(email: params[:user][:email])
    user.update!(activation_code: SecureRandom.urlsafe_base64,
                 activation_code_expires_at: Time.now + 2.minutes)
    url = new_user_session_url(activation_code: user.activation_code)
    LoginMailer.send_email(user, url).deliver_later
    redirect_to root_path, notice: 'Login link sent to your email, it will be valid for 2 minutes'
  end

end
