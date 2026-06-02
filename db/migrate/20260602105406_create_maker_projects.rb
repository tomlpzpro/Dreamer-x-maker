class CreateMakerProjects < ActiveRecord::Migration[8.1]
  def change
    create_table :maker_projects do |t|
      t.string :status
      t.references :project, null: false, foreign_key: true
      t.integer :maker_id

      t.timestamps
    end
    add_foreign_key :maker_projects, :users, column: :maker_id
  end
end
