class UserSessionsController < ApplicationController
  skip_before_action :require_login, only: [:new]

  def new
    if params[:activation_code].present?
      # check if a login token has expired
      user = User.where(activation_code: params[:activation_code])
                 .where('activation_code_expires_at > ?', Time.now).first
      if user
        # nullify the login token so it can't be used again
        user.update!(activation_code: nil, activation_code_expires_at: 1.year.ago)
        auto_login(user)
        redirect_to root_path, notice: 'Congrats. You are signed in!'
      else
        redirect_to root_path, alert: 'Invalid or expired login link'
      end
    else
      @user = User.new
    end

  end

  def create
    respond_to do |format|
      if (@user = login(params[:email], params[:password], params[:remember]))
        format.html { redirect_back_or_to(:users, notice: 'Login successfull.') }
        format.xml { render xml: @user, status: :created, location: @user }
      else
        format.html { flash.now[:alert] = 'Login failed.'; render action: 'new' }
        format.xml { render xml: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    logout
    redirect_to(:users, notice: 'Logged out!')
  end
end
