class UsersGetHearts < ActiveRecord::Migration
  def change
    add_column :users, :hearts, :text
  end
end
