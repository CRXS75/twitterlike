class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  def current_user
    #@current_user ||= User.find(session[:user_id]) if session[:user_id]
    @current_user ||= User.find_by_sql(['SELECT "users".* FROM "users" WHERE "users"."id" = ? LIMIT 1', session[:user_id]])[0] if session[:user_id]
  end

  helper_method :current_user

  def authorize
    redirect_to root_path unless current_user
  end

  def execute_statement(sql)
    # ActiveRecord::Sanitization::ClassMethods.
    results = ActiveRecord::Base.connection.execute(sql)
    if results.present?
      return results
    else
      return nil
    end
  end

  helper_method :execute_statement

end
