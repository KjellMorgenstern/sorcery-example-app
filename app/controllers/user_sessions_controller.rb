class UserSessionsController < ApplicationController
  skip_before_action :require_login, only: [:new]
  def new
    # we don't log in the user if a login token has expired
    user = User.where(activation_code: params[:activation_code])
               .where('activation_code_expires_at > ?', Time.now).first

    if user
      # nullify the login token so it can't be used again
      user.update!(activation_code: nil, activation_code_expires_at: 1.year.ago)

      # sorcery helper which logins the user
      auto_login(user)

      redirect_to root_path, notice: 'Congrats. You are signed in!'
    else
      redirect_to root_path, alert: 'Invalid or expired login link'
    end
  end


  def destroy
    logout
    redirect_to(:users, notice: 'Logged out!')
  end
end
