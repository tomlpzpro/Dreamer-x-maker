class AddDeadlineAndBudgetToProjects < ActiveRecord::Migration[8.1]
  def change
    add_column :projects, :deadline, :string
    add_column :projects, :budget, :integer
  end
end
