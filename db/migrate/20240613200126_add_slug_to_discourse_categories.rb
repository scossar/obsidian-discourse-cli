class AddSlugToDiscourseCategories < ActiveRecord::Migration[7.1]
  def change
    add_column :discourse_categories, :slug, :string
  end
end
