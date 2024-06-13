class CreateNotes < ActiveRecord::Migration[7.1]
  def change
    create_table :notes do |t|
      t.string :title, null: false, unique: true
      t.references :directory, foreign_key: true
      t.timestamps
    end
  end
end
