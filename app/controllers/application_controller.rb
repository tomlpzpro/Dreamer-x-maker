class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?


  # After signing in (login or sign up), always go back to the homepage,
  # logged in, instead of the page the visitor first tried to open.
  def after_sign_in_path_for(_resource)
    root_path
  end

  private

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:username, :phone_number, :adresse, :role, :skills])
  end
end
