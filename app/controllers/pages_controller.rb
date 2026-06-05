class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :home ]

  def home
    @projects = Project.where.missing(:maker_projects)

    # Projects already done: a maker has been accepted on them
    @completed_projects = Project
                            .joins(:maker_projects)
                            .where(maker_projects: { status: "accepted" })
                            .order(created_at: :desc)
  end
end
