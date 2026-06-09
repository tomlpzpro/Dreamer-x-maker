class AddDeliveryToMakerProjects < ActiveRecord::Migration[8.1]
  def change
    add_column :maker_projects, :rating, :integer
  end
end
