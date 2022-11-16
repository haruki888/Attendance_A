class AddEmployeeNumberToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :employee_number, :integer, default: false
  end
end
