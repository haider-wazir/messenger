class AddRecipientToMessages < ActiveRecord::Migration[7.1]
  def change
    add_reference :messages, :recipient, foreign_key: { to_table: :users }, null: true
  end
end
