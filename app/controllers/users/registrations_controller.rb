class Users::RegistrationsController < Devise::RegistrationsController
  def new
    @role = params[:role] || "dreamer"
    super
  end

  def create
    @role = params[:role]
    super
  end
end
