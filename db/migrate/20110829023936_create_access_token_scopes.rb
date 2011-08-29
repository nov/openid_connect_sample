class CreateAccessTokenScopes < ActiveRecord::Migration
  def self.up
    create_table :access_token_scopes do |t|
      t.belongs_to :access_token, :scope
      t.timestamps
    end
  end

  def self.down
    drop_table :access_token_scopes
  end
end
