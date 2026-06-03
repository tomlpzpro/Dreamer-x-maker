class ProfilesController < ApplicationController
  def new
  end

  def edit
    # Load the logged-in user so the form can be filled with their info
    @user = current_user
  end

  def show
    # The profile page always shows the logged-in user
    @user = current_user
  end

  def update
    @user = current_user
    if @user.update(profile_params)
      redirect_to profile_path, notice: "Profile updated."
    else
      # If saving fails, show the form again with the errors
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def profile_params
    params.require(:user).permit(:username, :email, :phone_number, :adresse, :skills, :profile_picture_url)
  end
end
