class CreateDiscourseNoteTags < ActiveRecord::Migration[6.1]
  def change
    create_table :note_tags do |t|
      t.references :note, null: false, foreign_key: true
      t.references :discourse_tag, null: false, foreign_key: true
      t.timestamps
    end
  end
end
