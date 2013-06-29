class CreateClients < ActiveRecord::Migration
  def self.up
    create_table :clients do |t|
      t.belongs_to :account
      t.string(
        :identifier,
        :secret,
        :name,
        :jwks_uri,
        :sector_identifier,
        :redirect_uris
      )
      t.boolean :dynamic, :native, :ppid, default: false
      t.datetime :expires_at
      t.text :raw_registered_json
      t.timestamps
    end
    add_index :clients, :identifier, unique: true
  end

  def self.down
    drop_table :clients
  end
end

