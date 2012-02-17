class AddNonce < ActiveRecord::Migration
  def up
    add_column :authorizations, :nonce, :string
    add_column :id_tokens, :nonce, :string
  end

  def down
    remove_column :authorizations, :nonce
    remove_column :id_token, :nonce
  end
end
