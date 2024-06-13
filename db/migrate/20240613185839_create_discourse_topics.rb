class CreateDiscourseTopics < ActiveRecord::Migration[7.1]
  def change
    create_table :discourse_topics do |t|
      t.string :discourse_url, null: false
      t.integer :discourse_id, null: false
      t.integer :discourse_post_id, null: false
      t.references :note, foreign_key: true
      t.timestamps
    end

    add_index :discourse_topics, :discourse_url, unique: true
    add_index :discourse_topics, :discourse_id, unique: true
    add_index :discourse_topics, :discourse_post_id, unique: true
  end
end
