class CreateConnectFacebooks < ActiveRecord::Migration
  def self.up
    create_table :connect_facebook do |t|
      t.belongs_to :account
      t.string :identifier, :access_token
      t.timestamps
    end
  end

  def self.down
    drop_table :connect_facebooks
  end
end
