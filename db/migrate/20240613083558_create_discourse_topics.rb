class CreateDiscourseTopics < ActiveRecord::Migration[6.1]
  def change
    create_table :discourse_topics do |t|
      t.string :discourse_url, null: false, unique: true
      t.integer :topic_id, null: false, unique: true
      t.integer :post_id, null: false, unique: true
      t.references :note, foreign_key: true
      t.timestamps
    end
  end
end
