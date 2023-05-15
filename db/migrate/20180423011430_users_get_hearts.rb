class UsersGetHearts < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :hearts, :text
  end
end
