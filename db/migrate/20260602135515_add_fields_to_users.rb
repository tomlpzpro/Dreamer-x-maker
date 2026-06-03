class AddFieldsToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :username, :string
    add_column :users, :phone_number, :string
    add_column :users, :adresse, :string
    add_column :users, :role, :string
    add_column :users, :skills, :string
  end
end
