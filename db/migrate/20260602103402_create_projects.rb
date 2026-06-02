class CreateProjects < ActiveRecord::Migration[8.1]
  def change
    create_table :projects do |t|
      t.string :title
      t.string :description
      t.integer :dreamer_id

      t.timestamps
    end
    add_foreign_key :projects, :users, column: :dreamer_id
  end
end
