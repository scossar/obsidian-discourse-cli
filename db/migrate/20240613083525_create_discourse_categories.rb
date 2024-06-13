class CreateDiscourseCategories < ActiveRecord::Migration[6.1]
  def change
    create_table :discourse_categories do |t|
      t.string :name, null: false, unique: true
      t.integer :category_id, null: false, unique: true
      t.timestamps
    end
  end
end
