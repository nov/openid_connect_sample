class CreateConnectGoogles < ActiveRecord::Migration
  def self.up
    create_table :connect_google do |t|
      t.belongs_to :account
      t.string :identifier, :access_token
      t.text :id_token
      t.timestamps
    end
  end

  def self.down
    drop_table :connect_googles
  end
end
