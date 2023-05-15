class CreateHostedFiles < ActiveRecord::Migration[6.1]
  def change
    create_table :hosted_files do |t|
      t.string :name
      t.text :content

      t.timestamps null: false
    end
  end
end
