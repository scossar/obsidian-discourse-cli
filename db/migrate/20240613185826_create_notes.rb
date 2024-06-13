class CreateNotes < ActiveRecord::Migration[7.1]
  def change
    create_table :notes do |t|
      t.string :title, null: false
      t.references :directory, foreign_key: true
      t.timestamps
    end

    add_index :notes, :title, unique: true
  end
end
