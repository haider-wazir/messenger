class CreateUnreadMessages < ActiveRecord::Migration[7.1]
  def change
    create_table :unread_messages do |t|
      t.references :user, null: false, foreign_key: true
      t.references :message, null: false, foreign_key: true
      t.timestamps
    end
    
    add_index :unread_messages, [:user_id, :message_id], unique: true
  end
end
