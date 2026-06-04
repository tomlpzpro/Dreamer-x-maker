class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :home ]

  def home
    @projects = Project.where.missing(:maker_projects)
  end
end
