class CreateDiscourseTags < ActiveRecord::Migration[6.1]
  def change
    create_table :discourse_tags do |t|
      t.string :name, null: false, unique: true
      t.timestamps
    end
  end
end
