class CreateDirectories < ActiveRecord::Migration[7.1]
  def change
    create_table :directories do |t|
      t.string :path, null: false, unique: true
      t.references :discourse_category, foreign_key: true
      t.timestamps
    end
  end
end
