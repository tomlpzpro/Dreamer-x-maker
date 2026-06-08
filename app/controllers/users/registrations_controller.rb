class Users::RegistrationsController < Devise::RegistrationsController
  def new
    # Role pre-selected from the link the visitor clicked (dreamer or maker).
    # Nil when coming from a plain "Créer un compte" link: nothing is selected.
    @role = params[:role]
    super
  end

  def create
    @role = params[:user][:role]
    super
  end
end
