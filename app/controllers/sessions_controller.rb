class SessionsController < ApplicationController

  include SessionsHelper

  def new
  end

  def create
    user = User.authenticate(params[:session][:login],
                             params[:session][:password])
    if user.nil?
      redirect_to '/signin'
    else
      session[:user_id] = user.id
      # sign_in user
      redirect_to '/feed'
    end

  end

  def destroy
    session[:user_id] = nil
    redirect_to root_path
  end
end
