class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  # view에서도 이 method를 사용하기 위해서 추가
  helper_method :user_signed_in?, :current_user
  
  def user_signed_in?
      session[:sign_in_user].present? # T이면 로그인 O
  end
  
  def authenticate_user!
      #로그인되지 않았을 경우에 로그인할 수 있는데로 ..
      # '/sign_in'을 prefix를 활용해 sign_in_path 로 바꿈
      redirect_to sign_in_path unless user_signed_in?
  end
  
  def current_user
      @current_user = User.find(session[:sign_in_user]) if user_signed_in?
  end
end
