class ExtendUsersToken < ActiveRecord::Migration[6.1]
  def change
    reversible do |dir|
      dir.up  {
        change_column :users, :image, :text
        change_column :users, :token, :text
      }
      dir.down {
        change_column :users, :image, :string
        change_column :users, :token, :string
      }
    end
  end
end
