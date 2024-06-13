class CreateDiscourseCategories < ActiveRecord::Migration[7.1]
  def change
    create_table :discourse_categories do |t|
      t.string :name, null: false
      t.integer :discourse_id, null: false
      t.timestamps
    end

    add_index :discourse_categories, :name, unique: true
    add_index :discourse_categories, :discourse_id, unique: true
  end
end
