class Users::RegistrationsController < Devise::RegistrationsController

  def new
    @role = params[:role] || "dreamer"
    super
  end

  def create
    super
  end

end
