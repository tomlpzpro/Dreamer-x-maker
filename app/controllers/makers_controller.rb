class MakersController < ApplicationController
  def show
    # The maker whose public profile we are looking at
    @maker = User.find(params[:id])

    # The projects this maker has delivered: the ones where his application
    # was accepted, most recent first.
    @creations = Project
                   .joins(:maker_projects)
                   .where(maker_projects: { maker_id: @maker.id, status: "accepted" })
                   .order(created_at: :desc)
  end
end
